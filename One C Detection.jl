using DataFrames
using CSV
using NativeFileDialog
using GLMakie 
using DataInterpolations
using RegularizationTools
using Statistics
#using Plots
#plotly()

function plot_default()
    plot(dpi=360,framestyle=:box,
    right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,top_margin=5*Plots.mm,
    legend=false)
end

#=function Inspect(x...; kw...)
    f,_=lines!(x...; kw...)
    DataInspector(f)
    display(GLMakie.Screen(),f)
    f
end=#

function EIS_overall()
    f_EIS=pick_file()
    df_EIS=CSV.read(f_EIS,DataFrame)

    idx=df_EIS."-Z'' (Ω)" .>0
    Zre=df_EIS."Z' (Ω)"[idx]
    Zimg=df_EIS."-Z'' (Ω)"[idx]
    Frequency=df_EIS."Frequency (Hz)"[idx]
    Z=df_EIS."Z (Ω)"[idx]
    Phase=df_EIS."-Phase (°)"[idx]
    C= 1 ./ (2*π .* Frequency .* Zimg)

    Nyquist=lines(Zre,Zimg,axis=(aspect=AxisAspect(1),))
    DataInspector(Nyquist)
    #display(GLMakie.Screen(),Nyquist)

    Bode=lines(Frequency,Phase,axis=(xscale=log10,))
    DataInspector(Bode)
    #display(GLMakie.Screen(),Bode)
    
    Module=lines(Frequency,Z,axis=(xscale=log10,))
    DataInspector(Module)
    #display(GLMakie.Screen(),Module)

    C_plot=lines(Frequency,C)
    display(GLMakie.Screen(),C_plot)

    savefolder=pick_folder()

    save(joinpath(savefolder,basename(f_EIS)*
    "_Nyquist.png"),Nyquist)
    save(joinpath(savefolder,basename(f_EIS)*
    "_Bode.png"),Bode)
    save(joinpath(savefolder,basename(f_EIS)*
    "_Module.png"),Module)
    save(joinpath(savefolder,basename(f_EIS)*
    "_C.png"),C_plot)
end
    

function Single_Frequency(d,λ)
    Freq_file=pick_file()
    df=CSV.read(Freq_file,DataFrame,delim =";")

    Potential=df."Potential (AC) (V)"
    Current=df."Current (AC) (A)"
    Time=df."Time domain (s)"
    Particular_Frequency=df."Frequency (Hz)"

    Smooth_Potential=RegularizationSmooth(Potential,Time,
    d; λ, alg = :fixed)
    Smooth_Current=RegularizationSmooth(Current,Time,
    d; λ, alg = :fixed)

    deriv_Potential=DataInterpolations.derivative.((Smooth_Potential,),
    range(first(Time),last(Time),length=4096),1)
    
    deriv_Current=DataInterpolations.derivative.((Smooth_Current,),
    range(first(Time),last(Time),length=4096),1)

    plot_Potential=lines(range(first(Time),last(Time),
    length=length(Time)),x->Smooth_Potential(x),
    axis=(xlabel="Time",ylabel="Potential",title="Potential @ $(first(Particular_Frequency)) Hz",))
    DataInspector(plot_Potential)
    
    scatter!(Time,Potential)
    display(GLMakie.Screen(),plot_Potential)

    plot_Current=lines(range(first(Time),last(Time),
    length=length(Time)),x->Smooth_Current(x),
    axis=(xlabel="Time (s)",ylabel="Current (A)",title="Current @ $(first(Particular_Frequency)) Hz",))
    DataInspector(plot_Current)
    
    scatter!(Time,Current)
    display(GLMakie.Screen(),plot_Current)

    plot_ratio_V=lines(Time, Current ./ deriv_Potential,
    axis=(title="ratio_V @ $(first(Particular_Frequency)) Hz",))
    DataInspector(plot_ratio_V)
    display(GLMakie.Screen(),plot_ratio_V)

    C_average=mean(Current ./ deriv_Potential)
    @show C_average

    #=plot_ratio_I=Inspect(Time,Potential ./ deriv_Current,
    axis=(title="ratio_I_$Particular_Frequency",aspect=DataAspect()))
    plot_ratio_doubleV=Inspect(Time,Potential ./ deriv_Potential,
    axis=(title="ratio_double_V_$Particular_Frequency",aspect=DataAspect()))
    plot_ratio_doubleI=Inspect(Time,Current ./ deriv_Current,
    axis=(title="ratio_double_I_$Particular_Frequency",aspect=DataAspect()))=#

    save_folder=pick_folder()

    save(joinpath(save_folder,
    basename(Freq_file)*"_Potential.png"),plot_Potential)
    save(joinpath(save_folder,
    basename(Freq_file)*"_Current.png"),plot_Current)
    save(joinpath(save_folder,basename(Freq_file)*
    "_Current_deriv(Potential).png"),plot_ratio_V)

    #=save(joinpath(save_folder,basename(Freq_file)*
    "_Potential_deriv(Current).png"),plot_ratio_I)
    save(joinpath(save_folder,basename(Freq_file)*
    "_Potential_deriv(Potential).png"),plot_ratio_doubleV)
    save(joinpath(save_folder,basename(Freq_file)*
    "_Current_deriv(Current).png"),plot_ratio_doubleI)=#

end

Single_Frequency(2,0.001)
EIS_overall()