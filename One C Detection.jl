using DataFrames
using CSV
using NativeFileDialog
using GLMakie 
using DataInterpolations
using RegularizationTools
#using Plots
#plotly()

function plot_default()
    plot(dpi=360,framestyle=:box,
    right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,top_margin=5*Plots.mm,
    legend=false)
end

function Inspect(x...; kw...)
    f,_=lines(x...; kw...)
    DataInspector(f)
    display(GLMakie.Screen(),f)
    f
end

function EIS_overall()
    f_EIS=pick_file()
    df_EIS=CSV.read(f_EIS,DataFrame)

    idx=df_EIS."-Z'' (Ω)" .>0
    Zre=df_EIS."Z' (Ω)"[idx]
    Zimg=df_EIS."-Z'' (Ω)"[idx]
    Frequency=df_EIS."Frequency (Hz)"[idx]
    Z=df_EIS."Z (Ω)"[idx]
    Phase=df_EIS."-Phase (°)"[idx]

    
    acs1=Axis(aspect = AxisAspect(1))
    acs2=Axis(xscale=log10, aspect = AxisAspect(1))

    Nyquist=Inspect(acs1,Zre,Zimg)
    Bode=Inspect(acs2,Frequency,Phase)
    Module=Inspect(acs2,Frequency,Z)

    savefolder=pick_folder()

    save(joinpath(savefolder,basename(Freq_file)*
    "_Nyquist.png"),Nyquist)
    save(joinpath(savefolder,basename(Freq_file)*
    "_Bode.png"),Bode)
    save(joinpath(savefolder,basename(Freq_file)*
    "_Module.png"),Module)
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

    plot_Potential=Inspect(range(first(Time),last(Time),
    length=length(Time)),x->Smooth_Potential(x),
    axis=(xlabel="Time",ylabel="Potential",title="Potential @ $(first(Particular_Frequency)) Hz",))

    plot_Current=Inspect(range(first(Time),last(Time),
    length=length(Time)),x->Smooth_Current(x),
    axis=(xlabel="Time (s)",ylabel="Current (A)",title="Current @ $(first(Particular_Frequency)) Hz",))

    plot_ratio_V=Inspect(Time, Current ./ deriv_Potential,
    axis=(title="ratio_V @ $(first(Particular_Frequency)) Hz",))

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