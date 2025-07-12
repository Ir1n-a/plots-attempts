using DataFrames
using CSV
using NativeFileDialog
using GLMakie
using DataInterpolations
using RegularizationTools
using Statistics

function EIS_step(d,λ,noise_value)
    f_EIS=pick_file()
    df_EIS=CSV.read(f_EIS,DataFrame)

    #indicators
    one_s_RC=[]
    only_RC=[]
    
    idx=[]
    Zre_0=df_EIS."Z' (Ω)"
    Zimg_0=df_EIS."-Z'' (Ω)"

    #removing some noise
    for i in eachindex(Zre_0[1:end-1])
        if (Zre_0[i] < Zre_0[i+1]) && (Zimg_0[i] > 0) && (Zre_0[i] > noise_value)
            push!(idx,i)
        end
    end

    #EIS variables
    Zre=df_EIS."Z' (Ω)"[idx]
    Zimg=df_EIS."-Z'' (Ω)"[idx]
    Frequency=df_EIS."Frequency (Hz)"[idx]
    Z=df_EIS."Z (Ω)"[idx]
    Phase=df_EIS."-Phase (°)"[idx]
   

    #plots & interpolation
    plot_before=lines(Zre,Zimg,axis=(title="Nyqusit_Before",))
    DataInspector(plot_before)
    display(GLMakie.Screen(),plot_before)

    plot_before_deriv=lines(Zre,Zimg ./ Zre,axis=(title="Deriv_Before",))
    DataInspector(plot_before_deriv)
    display(GLMakie.Screen(),plot_before_deriv)

    Smooth_Nyquist=RegularizationSmooth(Zimg,Zre,d;λ, alg= :fixed)

    plot_Nyquist=lines(range(first(Zre),last(Zre),length= 10*length(Zre)),
    x->Smooth_Nyquist(x),axis=(xlabel="Zre (Ω)",ylabel="Zimg (Ω)",title=
    "Nyquist"))
    DataInspector(plot_Nyquist)

    scatter!(Zre,Zimg)
    display(GLMakie.Screen(),plot_Nyquist)

    save_f=pick_folder()
    save(joinpath(save_f,basename(f_EIS)*
    "_Nyquist.png"),plot_Nyquist)

    Zre_range=range(first(Zre),last(Zre),length = 10*length(Zre))

    #derivative
    deriv_Nyquist=DataInterpolations.derivative.((Smooth_Nyquist,),
    Zre_range,2)
    plot_deriv_Nyquist=scatter(Zre_range,deriv_Nyquist,
    axis=(xlabel="Zre (Ω)",ylabel="d(Zimg)/d(Zr)",title="Nyquist_Derivative"))
    DataInspector(plot_deriv_Nyquist)
    display(GLMakie.Screen(),plot_deriv_Nyquist)

    #checking for configuration
    if issorted(Zimg)
        println("there's only series RC's present in the circuit")
        only_RC=true
    else
        println("there's something other than just series RC's present in the circuit")
        only_RC=false
    end

    current_interval=[]
    intervals=[]

    #storing intervals for when the second derivative is 0
    for j in eachindex(Zre_range)
        if (abs(deriv_Nyquist[j]) < 0.1)
            push!(current_interval,j)
        else 
            push!(intervals,copy(current_interval))
            empty!(current_interval)
        end
    end
    push!(intervals, current_interval)

    intervals_0=filter(!isempty, intervals)
    max_int=maximum(length.(intervals_0))

    #determining if there is only one RC series circuit involved
    if isempty(intervals_0)
        println("there are probably no series RCs")
        one_s_RC=false
    elseif max_int >10
        println("most likely there's at least one series RC")
        one_s_RC=true
    end

    max_int, index_max=findmax(length.(intervals_0))
    largest_int=intervals_0[index_max]
    
    #series resistance determination if only one series RC
    Rs=[]

    if one_s_RC
        Rs=first(Zre)
    else 
        println("There's more than one R in the circuit")
    end


    #some test for debugging 
    test_deriv=lines(Zre_range[largest_int],deriv_Nyquist[largest_int])
    DataInspector(test_deriv)
    display(GLMakie.Screen(),test_deriv)
    
    @show Zre_range[largest_int]
    intervals,Zre_range
    @show current_interval

    return Zre,Zimg,Frequency,Z,Phase,only_RC,one_s_RC,index_max,Rs
end

EIS_step(2,0.002,0)

function Current_Voltage(d1,λ1)
    f_I_V=pick_file()
    df_I_V=CSV.read(f_I_V,DataFrame,delim=";")

    # I & V variables
    Particular_Frequency=df_I_V."Frequency (Hz)"
    Period= 1 / first(Particular_Frequency)
    id=df_I_V."Time domain (s)" .<= Period
    Potential=df_I_V."Potential (AC) (V)"[id]
    Current=df_I_V."Current (AC) (A)"[id]
    Time=df_I_V."Time domain (s)"[id]

    #I & V plots 
    Smooth_Potential=RegularizationSmooth(Potential,Time,
    d1;λ=λ1, alg=:fixed)
    Smooth_Current=RegularizationSmooth(Current,Time,
    d1;λ=λ1, alg=:fixed)

    plot_Potential=lines(range(first(Time),last(Time),
    length= 10*length(Time)),x->Smooth_Potential(x),
    axis=(xlabel="Time (s)",ylabel="Potential (V)",title=
    "Potential @ $(first(Particular_Frequency)) Hz",))
        DataInspector(plot_Potential)
        scatter!(Time,Potential)
    display(GLMakie.Screen(),plot_Potential)

    plot_Current=lines(range(first(Time),last(Time),
    length= 10*length(Time)),x->Smooth_Current(x),
    axis=(xlabel="Time (s)",ylabel="Current (A)",title=
    "Current @ $(first(Particular_Frequency)) Hz",))
        DataInspector(plot_Current)
        scatter!(Time,Current)
    display(GLMakie.Screen(),plot_Current)

    # V first order derivative
    deriv_Potential=DataInterpolations.derivative.((Smooth_Potential,),
    range(first(Time),last(Time),length=10 * length(Time)),1)

    deriv_Current=DataInterpolations.derivative.((Smooth_Current,),
    range(first(Time),last(Time),length=10 * length(Time)),1)

    Time_range=range(first(Time),last(Time),length = 10*length(Time))

    deriv_Potential_plot=lines(Time_range,deriv_Potential,
    axis=(xlabel="Time (s)",ylabel="Potential Derivative (V/s)",title=
    "Potential Derivative @ $(first(Particular_Frequency)) Hz",))
        DataInspector(deriv_Potential_plot)
    display(GLMakie.Screen(),deriv_Potential_plot)

    deriv_Current_plot=lines(Time_range,deriv_Current,
    axis=(xlabel="Time (s)",ylabel="Current derivative (A/s)",title=
    "Current Derivative @ $(first(Particular_Frequency)) Hz",))
        DataInspector(deriv_Current_plot)
    display(GLMakie.Screen(),deriv_Current_plot)

end

Current_Voltage(2,0.002)