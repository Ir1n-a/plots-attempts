using Plots
using CSV
using DataFrames
using NumericalIntegration
using NativeFileDialog
plotlyjs()

function PowerEnergy_CorD(df,i,p)
    x=df."Corrected time (s)"
    y=df."WE(1).Potential (V)"

    E=[0.]
    P=[0.]
    Integral=integrate(x,y)
    V=maximum(y)
    t=maximum(x)
    C=(2*i*Integral)/((V^2)*p)
    E[1]=((C*V^2)/2)*3.6
    P.=E./t
    PE_plot=scatter!(P,E,dpi=360,
    xlabel="Power (W/kg)",ylabel="Energy (W*h/kg)",
    framestyle=:box,linewidth=2,
    right_margin=7*Plots.mm,top_margin=5*Plots.mm,
    legend=false)

end

function pick_PE(i,name,p)
    PE_overlay=pick_file()
    df=CSV.read(PE_overlay, DataFrame)
    Plot=PowerEnergy_CorD(df,i,p)
    display(Plot)
    savefig(Plot,name*"_PE.html")
end

nb=7
plot()

for i in 1:nb
    pick_PE(0.0005,"test_PE",33.525e-6)
end