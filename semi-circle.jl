using Plots
using DataFrames
using CSV
using NativeFileDialog
plotlyjs()

function semi_circle(df)
    idx=df."-Z'' (Ω)".>0
    Zre=df."Z' (Ω)"[idx]
    Z=df."Z (Ω)"[idx]
    Rs=minimum(Zre)
    Rp=maximum(Zre)
    r=(Rp-Rs)/2
    idr=Zre.<maximum(Zre)/2
    x=Zre[idr].-r
    q=((r).^2 .- (x).^2)
    print(q)
    Zre=Zre[idr]
    #id=q.>0
    Zimg=sqrt.(q)
    #Zre=Zre[id]
    print(Zre)
    return Zre,Zimg
end

function pick_data()
    fs=pick_file()
    df=CSV.read(fs, DataFrame)
    idx=df."-Z'' (Ω)".>0
    f=df."Frequency (Hz)"[idx]
    Z=df."Z (Ω)"[idx]
    Zre=df."Z' (Ω)"[idx]
    Zimg=df."-Z'' (Ω)"[idx]
    Z_t=sqrt.(Zre.^2 .+ Zimg.^2)
    p0=plot(Zre,Zimg)
    Zre_s,Zimg_s=semi_circle(df)
    p=plot(p0,Zre_s,Zimg_s)
    savefig(p,fs*"SemicircleN.html")
    #p1=plot(f,Z,xscale=:log10,linewidtg=3)
    #p2=plot(p1,f,Z_t,xscale=:log10,linestyle=:dot,linewidth=3)
    #savefig(p2,fs*"Semicircle.html")
end

pick_data()

plot()