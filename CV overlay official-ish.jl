using Plots
using CSV 
using DataFrames
using NativeFileDialog
plotlyjs()

function plot_CVo(df)
    x=df."WE(1).Potential (V)"
    y=df."WE(1).Current (A)"
    idx= df[!, :Scan] .==2 
    x=x[idx]
    y=y[idx]
    push!(x,first(x))
    push!(y,first(y))

    plot!(x,y*1000,dpi=360,title="Cyclic Voltammetry",
    xlabel="Potential (V)",ylabel="Current (mA)",
    framestyle=:box,linewidth=2, legend=false,
    right_margin=7*Plots.mm,top_margin=5*Plots.mm)
end
    
function pick_CVo()
    cv2=pick_file()
    df=CSV.read(cv2,DataFrame)
    CVo=plot_CVo(df)
    savefig(CVo,cv2*"_CVi.html")
end

k=7

for i in 1:k
    pick_CVo()
end 

plot()
