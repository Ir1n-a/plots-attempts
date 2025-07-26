using DataFrames
using CSV
using NativeFileDialog
using GLMakie
using NumericalIntegration
using DataInterpolations

function plots_format()
    Axis_Nyquist=Axis(xlabel="Zre (Ω)",ylabel="Zimg (Ω)",
    title = "Nyquist")
    Axis_Bode_Phase=Axis(xlabel="Frequency (Hz)",ylabel="Phase Difference (deg)",
    title = "Bode Phase Difference",xscale=:log10)
    Axis_Bode_Module=Axis(xlabel="Frequency (Hz)",ylabel="Z (Ω)",
    title = "Bode Module",xscale=:log10)

    Axis_CV=Axis(xlabel="Potential (V)",ylabel="Current (A)",
    title ="Cyclic Voltammetry")

    Axis_CD=Axis(xlabel="Time (s)",ylabel ="Potential (V)",
    title ="Charge/Discharge")

    return Axis_Nyquist,Axis_Bode_Phase,Axis_Bode_Module,Axis_CV,Axis_CD
end

function single_plot()
    single_file=pick_file()
    df=CSV.read(single_file,DataFrame)

    if names(df)[2] == "Frequency (Hz)"
        println("this is EIS")
        mode = "EIS"
    elseif names(df)[2] == "Time (s)"
        println("this is CV")
        mode = "CV"
    elseif names(df)[2] == "WE(1).Potential (V)" && df[!,5][1] >0
        println("this is C")
        mode = "C"
    elseif names(df)[2] == "WE(1).Potential (V)" && df[!,5][1] <0
        println("this is D")
        mode = "D"
    else println("this type of data is not supported by this program *shrug emoji*")
    end

    println(df[!,end][1])
    println(df[!,5][1])
    return mode
end

single_plot()