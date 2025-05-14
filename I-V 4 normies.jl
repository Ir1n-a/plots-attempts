using Plots
using DataFrames
using NativeFileDialog
using CSV
using DelimitedFiles
using DataInterpolations
plotly()
#gr()

function plot_default(p)
    plot(dpi=360,framestyle=:box,
    right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,top_margin=5*Plots.mm,
    legend=false,legendcolumns=p)
end

function I_V_normies(n,mode)
    files_vector=[]
    df_vector=[]
    plot_IV=plot_default(1)
    p_intp=plot_default(1)

    for i in 1:n
        f=pick_file()
        push!(files_vector,f)
        df=CSV.read(f,DataFrame)
        Potential=df."Potential applied (V)"
        Current=df."WE(1).Current (A)"
        Time=df."Time (s)"

        Intp_IV=CubicSpline(Current,Potential)

        if mode == "basic"
            plot_IV=plot(plot_IV,Potential,Current,xlabel="Potential (V)",
            ylabel="Current (A)",lw=3,hover=basename(files_vector[i]),
            xticks=[0,round(0.25*last(Potential);digits=1),round(0.5*last(Potential);digits=1),
            round(0.75*last(Potential),digits=1),round(last(Potential),digits=1)])
        
        elseif mode == "log"
            plot_IV=plot(plot_IV,Potential,Current,xlabel="Potential (V)",
            ylabel="Current (A)",lw=3,hover=basename(files_vector[i]),yscale=:log10,
            xticks=[0,round(0.25*last(Potential);digits=1),round(0.5*last(Potential);digits=1),
            round(0.75*last(Potential),digits=1),round(last(Potential),digits=1)])
        
        else plot_IV=plot!(range(first(Potential),last(Potential),length=5000),
            x->Intp_IV(x) ,legend=false,aspect_ratio=1,lw=3, hover=basename(files_vector[i]),
            xticks=[0,round(0.25*last(Potential);digits=1),round(0.5*last(Potential);digits=1),
            round(0.75*last(Potential),digits=1),round(last(Potential),digits=1)],
            xlabel="Potential (V)",ylabel="Current (A)")
        end
        
    end

    save_folder=pick_folder()
    savefig(plot_IV,joinpath(save_folder,basename(save_folder)*"_I_V_$mode.html"))
    
    @show files_vector
    #@show df_vector
end

I_V_normies(10,"log")
