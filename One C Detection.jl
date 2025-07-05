using DataFrames
using CSV
using NativeFileDialog
using WGLMakie 
using DataInterpolations
using RegularizationTools
using Plots
plotly()

function plot_default()
    plot(dpi=360,framestyle=:box,
    right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,top_margin=5*Plots.mm,
    legend=false)
end

function Single_Frequency(d,λ)
    Freq_file=pick_file()
    df=CSV.read(Freq_file,DataFrame,delim =";")

   #= plot_Potential=plot_default()
    plot_Current=plot_default()
    plot_ratio_V=plot_default()
    plot_ratio_I=plot_default()
    plot_ratio_doubleV=plot_default()
    plot_ratio_doubleI=plot_default()=#

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

    plot_Potential=plot(range(first(Time),last(Time),
    length=length(Time)),x->Smooth_Potential(x))

    plot_Current=plot(range(first(Time),last(Time),
    length=length(Time)),x->Smooth_Current(x))

    plot_ratio_V=plot(Time, Current ./ deriv_Potential)
    plot_ratio_I=plot(Time,Potential ./ deriv_Current)
    plot_ratio_doubleV=plot(Time,Potential ./ deriv_Potential)
    plot_ratio_doubleI=plot(Time,Current ./ deriv_Current)

    save_folder=pick_folder()

    savefig(plot_Potential,joinpath(save_folder,
    basename(Freq_file)*"_Potential.png"))
    savefig(plot_Current,joinpath(save_folder,
    basename(Freq_file)*"_Current.png"))

    savefig(plot_ratio_V,joinpath(save_folder,
    basename(Freq_file)*"_Current_deriv(Potential).png"))
    savefig(plot_ratio_I,joinpath(save_folder,
    basename(Freq_file)*"_Potential_deriv(Current).png"))

    savefig(plot_ratio_doubleV,joinpath(save_folder,
    basename(Freq_file)*"_Potential_deriv(Potential).png"))
    savefig(plot_ratio_doubleI,joinpath(save_folder,
    basename(Freq_file)*"_Current_deriv(Current).png"))

end

Single_Frequency(2,0.001)