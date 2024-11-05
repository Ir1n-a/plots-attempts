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
x=df."Frequency (Hz)"
x1=sortperm(x)
y=df."-Phase (°)"
y1=sortperm(y)
A=CubicSpline(y[x1],x[x1])
println(x[x1])
print(y[x1])
u=[5, 10, 100, 600, 4]
t=[20, 500, 760, 54, 422]
plot(t,u)
B=LinearInterpolation(u,t)
plot(x,y,xscale=:log10)
plot(B)
plot(10 .^range(-2, 5, length=10000), x->A(x),xscale=:log10,legend=false)
plot(10 .^range(-2, 5, length=10000), x->DataInterpolations.derivative(A,x,1),xscale=:log10,
legend=false)

scatter(x[x1],y[x1],xscale=:log10)


