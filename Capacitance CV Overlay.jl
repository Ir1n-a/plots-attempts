using Plots
using CSV
using DataFrames
using NumericalIntegration
using NativeFileDialog
plotlyjs()

function Index_CV(df,q,V,s,p)
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
    return i_cv/(V*s*p)
end
#also, the potential value in the capacitance formula is in modulus

#=function Capacitance_calculation(df,q,V,s)
    Index_CV(df,q)
    i_cv=integrate(x[index],y[index])
    return i_cv/(V*s)
end=#

function cycles_number(nb,indent)
    c=zeros(Int64,nb)
    for i in 2:nb
        c[i]=c[i-1].+indent
    end
    return c
end

cycles_number(7,5000)

#=function pick_CCV(q,V,s,cycles,indent,name)
    Ccv1=pick_file()
    df=CSV.read(Ccv1,DataFrame)
    C_CV=capacitance_CV(df,q,V,s,cycles,indent)
    savefig(C_CV,name*"Q$(q)_CapacitanceOverlay.html")
end=#

function pick_CCV_overlay(nb,q,V,s,name,indent,p)
    C_overlay=zeros(Float64,nb)
    for i in 1:nb
        Ccv1_overlay=pick_file()
        df=CSV.read(Ccv1_overlay, DataFrame)
        C_overlay[i]=Index_CV(df,q,V,s,p)
    end
    c=cycles_number(nb,indent)

    C_plot=scatter(c,C_overlay,dpi=360,
    xlabel="Nb of cycles",ylabel="Capacitance (F)",
    framestyle=:box,linewidth=2,
    right_margin=7*Plots.mm,top_margin=5*Plots.mm,
    legend=false)
    savefig(C_plot,name*"_CV_CapacitanceOverlay.html")
end

q=4
pick_CCV_overlay(7,q,1.5,50e-3,"TiNQ$q",5000,1)
 

