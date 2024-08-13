using Plots 
using CSV
using DataFrames
using NativeFileDialog
using Colors
using ColorSchemes
using NumericalIntegration
plotlyjs()

function plot_CD()
    plot(dpi=360,title="Charge-Discharge",
    xlabel="Time (s)",ylabel="Potential (V)",
    framestyle=:box,linewidth=2, leg=false,
    right_margin=7*Plots.mm,formatter=:plain,
    top_margin=5*Plots.mm)
end

function skip_html(file)
    fas=split(basename(file),".")
    if fas[end]=="html"
        return true
    else 
        return false
    end
end

function pick_type_multiple_CD()
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
    p_CD=plot_CD()

    for i in eachindex(f)
        df=f[i]
        s1=collect(first(df[!, [:"Time (s)"]]))
        x=df."Time (s)" .-s1
        y=df."WE(1).Potential (V)"

    p_CD=plot!(p_CD,x,y,color_palette=palette(:BuPu,10,rev=true),
    labels=l[i],linewidth=1.5,legend=:outerbottomright)
    end
    c=(pick_folder())
    savefig(p_CD,joinpath(c,basename(Fs)*"_CD.html"))
end

pick_type_multiple_CD()