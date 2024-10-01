using Plots
using DataFrames
using CSV
using NativeFileDialog
using Colors
using ColorSchemes
using NumericalIntegration
plotly()

function plot_default()
    plot(dpi=360,framestyle=:box,
    right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,top_margin=5*Plots.mm,
    legend=false)
end

function skip_html(file)
    fas=split(basename(file),".")
    if fas[end]=="html"
        return true
    else 
        return false
    end
end

function CV_preparation()
    x=df."WE(1).Potential (V)"
    y=df."WE(1).Current (A)"
    idx= df[!, :Scan] .==2 
    x=x[idx]
    y=y[idx]
    push!(x,first(x))
    push!(y,first(y))

    if x.*y.> 0 .&& x.>0
        q=1
    elseif x.*y.< 0 .&& x.>0
        q=2
    elseif x.*y.> 0 .&& x.<0
        q=3
    elseif x.*y.< 0 .&& x.<0
        q=4
    else println("I don't know what to tell you, you're screwed,jk")
    end

    i_cv=integrate(x,y)
    
    return x,y,i_cv,q
end

function data_plots(c,nb,b,l)
    fd=pick_folder()
    fl=[]
    for file in readdir(fd,join=true)
        if skip_html(file)
            @info "skipping $file"
            continue
        end
    df=CSV.read(file,DataFrame)
    push!(fl,df)
    end
    plot_Nyquist=plot_default()
    plot_Bode=plot_default()
    plot_Module=plot_default()
    
    #EIS 
    for i in eachindex(fl)
        df=fl[i]

        idx=df."-Z'' (Ω)".>0
        Frequency=df."Frequency (Hz)"[idx]
        Zre=df."Z' (Ω)"[idx]
        Zimg=df."-Z'' (Ω)"[idx]
        Z=df."Z (Ω)"[idx]
        Phase=df."-Phase (°)"[idx]

        plot_Nyquist=plot!(plot_Nyquist,Zre,Zimg,color_palette=palette(c,nb,rev=b),
        labels=l,marker=:circle,legend=true,xlabel="Zre (Ω)",ylabel="Zimg (Ω)")

        plot_Bode=plot!(plot_Bode,Frequency,Phase,color_palette=palette(c,nb,rev=b),
        labels=l,legend=true,xlabel="Frequency (Hz)",ylabel="-Phase Difference (°)"
        ,xscale=:log10)

        plot_Module=plot!(plot_Module,Frequency,Z,color_palette=palette(c,nb,rev=b),
        labels=l,legend=true,xlabel="Frequency (Hz)",ylabel="-Phase Difference (°)"
        ,xscale=:log10)
    end

    fs=pick_folder()
    savefig(plot_Nyquist,joinpath(fs,basename(fd)*"_Nyquist.html"))
    savefig(plot_Bode,joinpath(fs,basename(fd)*"_Bode.html"))
    savefig(plot_Module,joinpath(fs,basename(fd)*"_Module"))
end

data_plots(:BuPu,9,true,["test","2","3","4","5","6","7","8","9"])




    