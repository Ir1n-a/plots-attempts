using Plots 
using CSV
using DataFrames
using NativeFileDialog
using Colors
using ColorSchemes
using NumericalIntegration
plotlyjs()

function plot_CV()
    plot(dpi=360,title="Cyclic Voltammetry",
    xlabel="Potential (V)",ylabel="Current (mA)",
    framestyle=:box,linewidth=2, legend=false,
    right_margin=7*Plots.mm,top_margin=5*Plots.mm)
end

function skip_html(file)
    fas=split(basename(file),".")
    if fas[end]=="html"
        return true
    else 
        return false
    end
end

function pick_type_multiple_CV()
    Fs=pick_folder()
    f=[]
    l=["1","2","3","4","5","6","7","8","9"]
    for file in readdir(Fs,join=true)
        if skip_html(file) 
            @info "skipping $file"
            continue
        end
        df=CSV.read(file,DataFrame)
        push!(f,df)
    end
    p_CV=plot_CV()

    for i in eachindex(f)
        df=f[i]
        x=df."WE(1).Potential (V)"
        y=df."WE(1).Current (A)"
        idx= df[!, :Scan] .==2 
        x=x[idx]
        y=y[idx]
        push!(x,first(x))
        push!(y,first(y))


    p_CV=plot!(p_CV,x,y*1000,color_palette=palette(:BuPu,10,rev=true),
    labels=l[i],linewidth=1.5,legend=:outerbottomright)
    end
    c=(pick_folder())
    savefig(p_CV,joinpath(c,basename(Fs)*"_CV.html"))
end

pick_type_multiple_CV()