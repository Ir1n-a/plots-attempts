using DataFrames
using CSV
using NativeFileDialog
using WGLMakie 
using DataInterpolations
using RegularizationTools
#using Plots
gr()


fl=pick_file()
df_f=CSV.read(fl,DataFrame, delim=";")
fs=pick_file()
df_EIS=CSV.read(fs,DataFrame)
names(df_f)
df_f[!, ["Potential (AC) (V)","Current (AC) (A)","Time domain (s)","Frequency (Hz)"]]
df_EIS
names(df_EIS)

Xc=df_EIS."-Z'' (Ω)"
f=df_EIS."Frequency (Hz)"
ReZ=df_EIS."Z' (Ω)"
C= 1 ./ (2 * π .*f .* Xc)

Potential=df_f."Potential (AC) (V)"
Current=df_f."Current (AC) (A)"
Time=df_f."Time domain (s)"
Particular_Frequency=df_f."Frequency (Hz)"
d=2
λ = 0.001
Smooth=RegularizationSmooth(Potential,Time, d; λ, alg = :fixed)
Smooth_Current=RegularizationSmooth(Current,Time, d; λ, alg = :fixed)

L_intp_V=CubicSpline(Potential,Time)
L_intp_I=CubicSpline(Current,Time)
lines(range(first(Time),last(Time),length=5000),
x->Smooth(x))

lines(range(first(Time),last(Time),length=5000),
x->Smooth_Current(x))
scatter!(Time,Current,markersize=3)

scatter!(Time,Potential,markersize=3)

lines(range(first(Time),last(Time),length=5000),
x->L_intp_V(x))

plot(range(first(Potential),last(Potential),length=5000),
x->Smooth(x))


lines(Time,Potential)
lines(Time,Current)
DataInspector(current_figure())


lines(f,C,axis=(xscale=log10,))
lines(ReZ,Xc,axis= (aspect = AxisAspect(1),))

lines(f,ReZ,axis=(xscale=log10,))