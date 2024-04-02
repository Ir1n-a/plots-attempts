using Plots
using CSV
using DataFrames
using NumericalIntegration
using NativeFileDialog
plotlyjs()

function Capacitance_CorD(df,i,p)
    x=df."Corrected time (s)"
    y=df."WE(1).Potential (V)"

    Integral=integrate(x,y)
    V=maximum(y)
    C=(2*i*Integral)/((V^2)*p)
    return C
end

function cycles_number_CD(nb,indent)
    c=zeros(Int64,nb)
    for i in 2:nb
        c[i]=c[i-1].+indent
    end
    return c
end

function pick_CCD(i,name,nb,indent,p)
    C_overlay_CD=zeros(Float64,nb)
    for j in 1:nb
        CCD_overlay=pick_file()
        df=CSV.read(CCD_overlay, DataFrame)
        C_overlay_CD[j]=Capacitance_CorD(df,i,p)
    end
    c_cd=cycles_number_CD(nb,indent)

    CCD_plot=scatter(c_cd,C_overlay_CD,dpi=360,
    xlabel="Nb of cycles",ylabel="Capacitance (F)",
    framestyle=:box,linewidth=2,
    right_margin=7*Plots.mm,top_margin=5*Plots.mm,
    legend=false)
    savefig(CCD_plot,name*"_CD_Capacitance_overlay.html")
end


pick_CCD(0.0005,"test_overlay_C_p",7,5000,1)