using DataFrames
using CSV
using NativeFileDialog
using WGLMakie 


fl=pick_file()
df_f=CSV.read(fl,DataFrame, delim=";")
fs=pick_file()
df_EIS=CSV.read(fs,DataFrame)
names(df_EIS)
df[!, ["Potential (AC) (V)","Current (AC) (A)"]]
df_EIS
names(df_EIS)

Xc=df_EIS."-Z'' (Ω)"
f=df_EIS."Frequency (Hz)"
ReZ=df_EIS."Z' (Ω)"
C= 1 ./ (2 * π .*f .* Xc)

lines(f,C,axis=(xscale=log10,))
lines(ReZ,Xc,axis= (aspect = AxisAspect(1),))
DataInspector(current_figure())