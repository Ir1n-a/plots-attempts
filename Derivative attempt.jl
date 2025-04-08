using Plots
using DataFrames
using CSV
using NativeFileDialog
using Colors
using ColorSchemes
using DataInterpolations
plotly()

# I will import the graphs from the plots program in the future,
#for now I will keep it like this for testing 

f=pick_file()
df=CSV.read(f,DataFrame)
ix=(df."-Z'' (Ω)" .<= 30) .& (df."-Z'' (Ω)" .>0) 
x=df."Z' (Ω)"[ix]
deleteat!(x,31)
x1=sortperm(x)
y=df."-Z'' (Ω)"[ix]
#y1=sortperm(y)
deleteat!(y,31)
A=CubicSpline(y[x1],x[x1])
println(x[x1])
print(y[x1])
#=u=[5, 10, 100, 600, 4]
t=[20, 500, 760, 54, 422]
plot(t,u)
B=LinearInterpolation(u,t)=#
scatter(x,y,legend=false)
plot(B)
p_linear_intp=plot(range(102.5,111.72,length=100), x->A(x),legend=false)
fole=pick_file()
savefig(p_linear_intp,joinpath(@__DIR__,basename(fole)*"_Nyquist_linearintp.html"))
plot(range(102.5,111.72,length=100), x->DataInterpolations.derivative(A,x,1),xscale=:log10,
legend=false)

scatter(x[x1],y[x1],xscale=:log10)

@__DIR__
