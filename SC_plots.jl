using Plots
using CSV
using DataFrames
using NumericalIntegration
using NativeFileDialog
plotly()

function plot_Nyquist(df)
    x=df."Z' (Ω)"
    y=df."-Z'' (Ω)"
    plot(x,y,seriestype=:scatter,dpi=360,
    xlabel="Zre (Ω)",ylabel="-Zimg (Ω)",
right_margin=7*Plots.mm,framestyle=:box,
linewidth=2, formatter=:plain,ylims=[0,
maximum(y)+0.02*maximum(y)],size=(500,500),
markersize=3, top_margin=5*Plots.mm,legend=false)
end

function plot_Bode(df)
    x=df."Frequency (Hz)"
    y=df."-Phase (°)"
    plot(x,y,dpi=360,xscale=:log10,
    xlabel="Frequency (Hz)",ylabel="Phase Difference (deg)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain, xticks=10.0 .^(-2:5),
    top_margin=5*Plots.mm,legend=false)
    
end

function plot_Module(df)
    x=df."Frequency (Hz)"
    y=df."Z (Ω)"
    plot(x,y,dpi=360,xscale=:log10,
    xlabel="Frequency (Hz)",ylabel="Z (Ω)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain, xticks=10.0 .^(-2:5),leg=false,
    top_margin=5*Plots.mm)
end

function plot_CV(df)
    x=df."WE(1).Potential (V)"
    y=df."WE(1).Current (A)"
    idx= df[!, :Scan] .==2 
    x=x[idx]
    y=y[idx]
    push!(x,first(x))
    push!(y,first(y))

    plot(x,y*1000,dpi=360,
    xlabel="Potential (V)",ylabel="Current (mA)",
    framestyle=:box,linewidth=2,
    right_margin=7*Plots.mm,top_margin=5*Plots.mm,legend=false)
end

function plot_CD(df,s1)
    x=df."Time (s)" .-s1
    y=df."WE(1).Potential (V)"

    plot(x,y,dpi=360,
    xlabel="Time (s)",ylabel="Potential (V)",
    framestyle=:box,linewidth=2,
    right_margin=7*Plots.mm,formatter=:plain,
    top_margin=5*Plots.mm,legend=false)
end

function capacitance_CV(df,q,V,s,p)
    x=df."WE(1).Potential (V)"
    y=df."WE(1).Current (A)"
    idx= df[!, :Scan] .==2 
    x=x[idx]
    y=y[idx]
    push!(x,first(x))
    push!(y,first(y))

    if q==1
        index=x.*y.> 0 .&& x.>0
    elseif q==2
        index=x.*y.< 0 .&& x.>0
    elseif q==3
        index=x.*y.> 0 .&& x.<0
    elseif q==4
        index=x.*y.< 0 .&& x.<0
    else 
        error("q is only up to 4, integer, not $q")
    end 
    i_cv=integrate(x[index],y[index])
    C_cv=i_cv/(V*s*p)
    print(C_cv," ")
    return i_cv,C_cv
end

function Capacitance_CD(df,I,p)
    x=df."Corrected time (s)"
    y=df."WE(1).Potential (V)"

    Integral=integrate(x,y)
    V=maximum(y)
    C=(2*I*Integral)/((V^2)*p)
    print(V," ",C)
    return C
end

function method(df,q,V,s,p,I)
    n=names(df)
    m="0"
    if(n[2]=="Frequency (Hz)")
        m="eis"
        P1=plot_Nyquist(df)

        P2=plot_Bode(df)

        P3=plot_Module(df)

        return m,P1,P2,P3
    elseif(n[1]=="Potential applied (V)")
        m="cv"
        P1=plot_CV(df)
        i_cv,C_cv=capacitance_CV(df,q,V,s,p)
        return m,P1
    elseif(n[1]=="Time (s)")
        if(df."WE(1).Current (A)"[1]>0)
            m="cd+"
            c=plot_CD(df,df."Time (s)"[1])
            C_c=Capacitance_CD(df,I,p)
            return m,P1
        elseif(df."WE(1).Current (A)"[1]<0)
            m="cd-"
            d=plot_CD(df,df."Time (s)"[1])
            C_d=Capacitance_CD(df,I,p)
            return m,P1
        end
    end
end

function pick_type_single(q,V,s,p,I)
    F=pick_file()
    df=CSV.read(F,DataFrame)
    m,P1=method(df,q,V,s,p,I)
    print(m)
    if(m=="eis")
        m,P1,P2,P3=method(df,q,V,s,p,I)
        savefig(P1,F*"_Nyquist.html")
        savefig(P2,F*"_Bode.html")
        savefig(P3,F*"_Module.html")
    elseif(m=="cv")
        savefig(P1,F*"_CV.html")
    elseif(m=="cd+")
        savefig(P1,F*"_C.html")
    elseif(m=="cd-")
        savefig(P1,F*"_D.html")
    end
end

pick_type_single(1,1.5,0.05,1,0.0005)

function pick_type_multiple()
    Fs=pick_folder()
    df=CSV.read(readdir(Fs,join=true),DataFrame)
    print(df)
end

pick_type_multiple()