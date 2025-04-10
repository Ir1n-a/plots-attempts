using Plots
using DataFrames
using CSV
using NativeFileDialog
using Colors
using ColorSchemes
using NumericalIntegration
plotly()
#gr()

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

    #=if x.*y.> 0 .&& x.>0
        q=1
    elseif x.*y.< 0 .&& x.>0
        q=2
    elseif x.*y.> 0 .&& x.<0
        q=3
    elseif x.*y.< 0 .&& x.<0
        q=4
    else println("I don't know what to tell you, you're screwed,jk")
    end=#S

    #i_cv=integrate(x,y)
    
    return x,y
end

function data_plots_EIS(c,nb,b)
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
        #=labels=l[i],=#marker=:circle,legend=true,xlabel="Zre (Ω)",ylabel="Zimg (Ω)")

        plot_Bode=plot!(plot_Bode,Frequency,Phase,color_palette=palette(c,nb,rev=b),
        #=labels=l[i],=#legend=true,xlabel="Frequency (Hz)",ylabel="-Phase Difference (°)"
        ,xscale=:log10)

        plot_Module=plot!(plot_Module,Frequency,Z,color_palette=palette(c,nb,rev=b),
        #=labels=l[i],=#legend=true,xlabel="Frequency (Hz)",ylabel="-Phase Difference (°)"
        ,xscale=:log10)
    end

    fs=pick_folder()
    savefig(plot_Nyquist,joinpath(fs,basename(fd)*"_Nyquist.html"))
    savefig(plot_Bode,joinpath(fs,basename(fd)*"_Bode.html"))
    savefig(plot_Module,joinpath(fs,basename(fd)*"_Module"))
end

function data_plots_CV(c,nb,b,l)
    fcv=pick_folder()
    flcv=[]

    for file in readdir(fcv,join=true)
        if skip_html(file)
            @info "skipping $file"
            continue
        end
    df=CSV.read(file,DataFrame)
    push!(flcv,df)
    end

    plot_CV=plot_default()

    for i in eachindex(flcv)
        df=flcv[i]

        x=df."WE(1).Potential (V)"
        y=df."WE(1).Current (A)"
        idx= df[!, :Scan] .==2 
        x=x[idx]
        y=y[idx]
        push!(x,first(x))
        push!(y,first(y))

        plot_CV=plot!(plot_CV,x,y.*1000,linewidth=2,xlabel="Potential (V)",
        ylabel="Current (mA)",color_palette=palette(c,nb,rev=b),labels=l[i],
        legend=false)
    end

    fsv=pick_folder()
    savefig(plot_CV,joinpath(fsv,basename(fcv)*"_CV"))
end

function data_plots_C(c,nb,b)
    fcd=pick_folder()
    flcd=[]

    for file in readdir(fcd,join=true)
        if skip_html(file)
            @info "skipping $file"
            continue
        end
    df=CSV.read(file,DataFrame)
    push!(flcd,df)
    end

    p_C=plot_default()
    p_CD_both=plot_default()
    t_added=[]

    for i in eachindex(flcd)
        df=flcd[i]
        s1=collect(first(df[!, [:"Time (s)"]]))
        x=df."Time (s)" .-s1
        y=df."WE(1).Potential (V)"
        x_cd=df."Corrected time (s)"
        I=df."WE(1).Current (A)"

        if(I[1] .> 0)
            push!(t_added,last(x_cd))
        else println("not charging file")
        end

        p_C=plot!(p_C,x,y,color_palette=palette(c,nb,rev=b),
        linewidth=2,legend=:outerbottomright)
        #more work is needed for this, starting the discharge curve from the last charge x(time) value

    end

    print(t_added)

    fsc=pick_folder()
    savefig(p_C, joinpath(fsc,basename(fcd)*"_CD"))

    return p_C,t_added
end

function data_plots_CD(c,nb,b)
    fcd=pick_folder()
    flcd=[]
    x_cd_f=[]
    for file in readdir(fcd,join=true)
        if skip_html(file)
            @info "skipping $file"
            continue
        end
    df=CSV.read(file,DataFrame)
    push!(flcd,df)
    end

    p_CD,t=data_plots_C(c,nb,b)

    for i in eachindex(flcd)
        df=flcd[i]
        y=df."WE(1).Potential (V)"
        x_cd=df."Corrected time (s)"
        I=df."WE(1).Current (A)"
        
        for j in eachindex(x_cd)
            push!(x_cd,x_cd[j] .+ t[i])
        end
    end
    return x_cd 
end

data_plots_C(:BuPu,9,true)

data_plots_CD(:BuPu,9,true)

data_plots_CV(:watermelon,9,true,["50","100","250","500"])

data_plots_EIS(:BuPu,16,true)



    