using WGLMakie
using DataFrames
using CSV
using NativeFileDialog
using DataInterpolations

function EIS(R,C,Ro)
    fls=[]
    fl=pick_file()
    push!(fls,fl)
    df=CSV.read(fls,DataFrame)

    idx=df."-Z'' (Ω)" .>0
    Zre=df."Z' (Ω)"[idx]
    Zimg=df."-Z'' (Ω)"[idx]
    Frequency=df."Frequency (Hz)"[idx]
    Z=df."Z (Ω)"[idx]
    Phase=df."-Phase (°)"[idx]

    fig=Figure()
    #acs1=Axis(fig[1,1], aspect = AxisAspect(1))
    acs2=Axis(fig[1,1],xscale=log10, aspect = AxisAspect(1))

    #Nyquist=lines!(acs1,Zre,Zimg)
    #Bode_Phase=lines!(acs2,Frequency,Phase)

    
    Zre_t= Ro .+ R ./ (1 .+ (2 .* π .* Frequency .* R .* C) .^2)
    Zimg_t=(2 .* π .* Frequency .* (R .^2) .*C) ./ (1 .+ (2 .* π .* Frequency .* R .* C) .^2)
    tg= Zimg_t ./ Zre_t
    angle=rad2deg.(atan.(tg))

    lines!(acs2,Frequency,angle)


    current_figure()
end

EIS(10,0.000001,2)