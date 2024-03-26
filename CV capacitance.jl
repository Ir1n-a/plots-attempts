using Plots
using CSV
using DataFrames 
using NativeFileDialog
using NumericalIntegration
plotlyjs()

#= At the semi-last, the capacitance calculation from CV curves, my least
favourite part. Sure, you can go the easy route of calculating the capacitance
from the whole curve, but that route is not only easy, it is also incorrect. You calculate the
capacitance when the total charge that can accumulate on each plate is present at once, 
not summing the charge and the discharge in one value as if that made sense. Different 
differential equations, the same charge added twice, it doesn't work that way...
So, the program...I have 4 quadrants if the CV is from -V to +V and only two if the 
CV is from 0 to +V or 0 to -V. Either way, the conditions are the same for their respective 
quadrants. Initially I wrote each capacitance calculation for each quadrant, but it would be more
efficient to create a function for capacitance calcualtion and pass the quadrant number as a 
variable of said function with if conditions deciding which to calculate 1,2,3 or 4 with the
mention that in the case of 0 to +/-V the quadrants will be either 1&2 or 
3&4 respectivelly. Then this shall be the strategy for this one, on with the programming, yeah.=# 

function capacitance_CV(df,q,V,s)
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
    C_cv=i_cv/(V*s)
    print(C_cv," ")

    plot(x,y*1000,dpi=360,title="Cyclic Voltammetry",
        xlabel="Potential (V)",ylabel="Current (mA)",
        framestyle=:box,linewidth=2,
        right_margin=7*Plots.mm,top_margin=5*Plots.mm,
        legend=(0.4,-0.2),
        label="Capacitance_Q$q= "*sprint(show, C_cv, context=:compact => true)*" F")
end
#also, the potential value in the capacitance formula is in modulus
function pick_CCV(q,V,s)
    Ccv1=pick_file()
    df=CSV.read(Ccv1,DataFrame)
    C_CV=capacitance_CV(df,q,V,s)
    savefig(C_CV,Ccv1*"Q$(q)_Capacitance.html")
end

pick_CCV(1,1.5,0.05) 