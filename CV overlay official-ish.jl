using Plots
using CSV 
using DataFrames
using NativeFileDialog
#plotlyjs()
gr()


function plot_CV()
    p=plot(dpi=360,title="Cyclic Voltammetry",
    xlabel="Potential (V)",ylabel="Current (mA)",
    framestyle=:box,linewidth=2, legend=:outerbottom,
    right_margin=7*Plots.mm,top_margin=5*Plots.mm)
end
    
function pick_CVo(k)
    
    plot_CV=plot(dpi=360, size=(600,500),
    xlabel="Potential (V)",ylabel="Current (mA)",
    framestyle=:box,linewidth=10, legend=:outerbottom,
    right_margin=7*Plots.mm,top_margin=5*Plots.mm)

    for i in 1:k
        cv2=pick_file()
        df=CSV.read(cv2,DataFrame)
        x=df."WE(1).Potential (V)"
        y=df."WE(1).Current (A)"
        idx= df[!, :Scan] .==2 
        x=x[idx]
        y=y[idx]
        push!(x,first(x))
        push!(y,first(y))

        plot_CV=plot(plot_CV,x,y .*1000,label=basename(cv2))
    end

    save_folder=pick_folder()
    savefig(plot_CV,save_folder*"_CV.png")
    
end

pick_CVo(3)
#k=3

for i in 1:k
    pick_CVo()
end 

plot()
