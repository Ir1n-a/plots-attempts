using DataFrames
using CSV
using NativeFileDialog
using GLMakie
using NumericalIntegration
using DataInterpolations

function single_plot_mode_selection()
    println("pick data file")
    single_file=pick_file()
    df=CSV.read(single_file,DataFrame)

    if names(df)[2] == "Frequency (Hz)"
        println("this is EIS")
        mode = "EIS"
    elseif names(df)[4] == "Scan"
        println("this is CV")
        mode = "CV"
    elseif names(df)[2] == "WE(1).Potential (V)" && df[!,5][1] >0
        println("this is C")
        mode = "C"
    elseif names(df)[2] == "WE(1).Potential (V)" && df[!,5][1] <0
        println("this is D")
        mode = "D"
    elseif names(df)[4] == "Index" && names(df)[5] == "WE(1).Potential (V)"
        println("this is I-V")
        mode = "I-V"
    else println("this type of data is not supported by this program *shrug emoji*")
    end
    return mode,single_file,df
end

single_plot_mode_selection()

function single_plot(clr)
    mode,single_file,df=single_plot_mode_selection()
    println("pick save folder")
    save_folder=pick_folder()

    if mode == "EIS"

        idx_EIS=df."-Z'' (Ω)" .>0
        Zre=df."Z' (Ω)"[idx_EIS]
        Zimg=df."-Z'' (Ω)"[idx_EIS]
        Frequency=df."Frequency (Hz)"[idx_EIS]
        Z=df."Z (Ω)"[idx_EIS]
        Phase=df."-Phase (°)"[idx_EIS]

        plot_Nyquist=lines(Zre,Zimg,axis=(title=basename(single_file)*"_Nyquist",xlabel="Zre (Ω)",
        ylabel="Zimg (Ω)"),color=clr)
        DataInspector(plot_Nyquist)
        display(GLMakie.Screen(),plot_Nyquist)

        save(joinpath(save_folder,basename(single_file)*"_Nyquist.png"),plot_Nyquist)

        plot_Bode_Phase=lines(Frequency,Phase,axis=(title=basename(single_file)*"_Bode Phase Difference",
        xlabel="Frequency (Hz)",ylabel="Phase (deg)",
        xscale=log10),color=clr)
        DataInspector(plot_Bode_Phase)
        display(GLMakie.Screen(),plot_Bode_Phase)

        save(joinpath(save_folder,basename(single_file)*"_Bode Phase.png"),plot_Bode_Phase)

        plot_Bode_Module=lines(Frequency,Z,axis=(title=basename(single_file)*"_Bode Module",
        xlabel="Frequency (Hz)",ylabel="Z (Ω)",xscale=log10),color=clr)
        DataInspector(plot_Bode_Module)
        display(GLMakie.Screen(),plot_Bode_Module)

        save(joinpath(save_folder,basename(single_file)*"_Bode Module.png"),plot_Bode_Module)
        
        #println(basename(single_file))
    elseif mode == "CV"

        idx_CV= df[!, :Scan] .==2
        Potential=df."WE(1).Potential (V)"[idx_CV]
        Current=df."WE(1).Current (A)"[idx_CV]
        push!(Potential,first(Potential))
        push!(Current,first(Current))

        plot_CV=lines(Potential,Current,axis=(title=basename(single_file)*"_Cyclic Voltammetry",
        xlabel="Potential (V)",ylabel="Current (A)"),color=clr)
        DataInspector(plot_CV)
        display(GLMakie.Screen(),plot_CV)

        save(joinpath(save_folder,basename(single_file)*"_CV.png"),plot_CV)

    elseif mode == "I-V"
        Current=df."WE(1).Current (A)"
        Potential=df."WE(1).Potential (V)"

        plot_IV=lines(Potential,Current,axis=(title=basename(single_file)*"_I-V",
        xlabel="Potential (V)",ylabel="Current (A)"),color=clr)
        DataInspector(plot_IV)
        display(GLMakie.Screen(),plot_IV)

        save(joinpath(save_folder,basename(single_file)*"_I-V.png"),plot_IV)

    elseif mode =="C" || mode =="D"
        Time=df."Corrected time (s)"
        Potential=df."WE(1).Potential (V)"

        if mode == "C"
            plot_C=lines(Time,Potential,axis=(title=basename(single_file)*"_Charge",
            xlabel="Time (s)",ylabel="Potential (V)"),color=clr)
            DataInspector(plot_C)
            display(GLMakie.Screen(),plot_C)

        save(joinpath(save_folder,basename(single_file)*"_C.png"),plot_C)
        
        elseif mode == "D"
            plot_D=lines(Time,Potential,axis=(title=basename(single_file)*"_Discharge",
            xlabel="Time (s)",ylabel="Potential (V)"),color=clr)
            DataInspector(plot_D)
            display(GLMakie.Screen(),plot_D)

        save(joinpath(save_folder,basename(single_file)*"_D.png"),plot_D)
        end
    end
end

single_plot(:mediumorchid4)

# now for the overlay I could do a brute force thing and
#just iterate the single version, but I'm not gonna do that....maybe :d
#I need the graph label though, so I probably shoud write a separate version
#with permutations which check whether it's the single option or the multiple version