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
    x->Smooth_Nyquist(x))
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
    plot_deriv_Nyquist=lines(Zre_range,deriv_Nyquist)
    DataInspector(plot_deriv_Nyquist)
    display(GLMakie.Screen(),plot_deriv_Nyquist)

    #checking for configuration
    if issorted(Zimg)
        println("there's only series RC's present in the circuit")
        one_s_RC=true
    else
        println("there's something other than just series RC's present in the circuit")
        one_s_RC=false
    end

    current_interval=[]
    intervals=[]

    for j in eachindex(Zre_range)
        if (deriv_Nyquist[j] < 0.1) && (deriv_Nyquist[j] > -0.1)
            push!(current_interval,j)
        else 
            push!(intervals,current_interval)
            current_interval=[]
        end
    end

    intervals_0=filter(!isempty, intervals)
    max_int=maximum(length.(intervals_0))

    if isempty(intervals_0)
        println("there are probably no series RCs")
    elseif max_int >10
        println("most likely there's at least one series RC")
    end

end

EIS_step(2,0.002,0)