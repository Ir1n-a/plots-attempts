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
y=df."-Phase (°)"
A=AkimaInterpolation(y,x)
u=[5, 10, 100, 600, 4]
t=[20, 500, 760, 54, 422]
plot(t,u)
B=LinearInterpolation(u,t)
plot(x,y,xscale=:log10)
plot(B)
plot(A)

