using DataFrames
using CSV
using NativeFileDialog
using GLMakie
using DataInterpolations
using RegularizationTools
using Statistics

function EIS_step(d,λ)
    f_EIS=pick_file()
    df_EIS=CSV.read(f_EIS,DataFrame)

    idx=[]
    Zre_0=df_EIS."Z' (Ω)"
    Zimg_0=df_EIS."-Z'' (Ω)"

    for i in eachindex(Zre_0[1:end-1])
        if (Zre_0[i] < Zre_0[i+1]) && (Zimg_0[i] > 0)
            push!(idx,i)
        end
    end

    Zre=df_EIS."Z' (Ω)"[idx]
    Zimg=df_EIS."-Z'' (Ω)"[idx]
    Frequency=df_EIS."Frequency (Hz)"[idx]
    Z=df_EIS."Z (Ω)"[idx]
    Phase=df_EIS."-Phase (°)"[idx]

    Smooth_Nyquist=RegularizationSmooth(Zimg,Zre,d;λ, alg= :fixed)

    plot_Nyquist=lines(range(first(Zre),last(Zre),length= 10*length(Zre)),
    x->Smooth_Nyquist(x))
    DataInspector(plot_Nyquist)

    scatter!(Zre,Zimg)
    display(GLMakie.Screen(),plot_Nyquist)

    save_f=pick_folder()
    save(joinpath(save_f,basename(f_EIS)*
    "_Nyquist.png"),plot_Nyquist)

    if issorted(Zimg)
        "there's only series RC's present in the circuit"
    else "there's something other than just series RC's present in the circuit"
    end

end

EIS_step(2,0.002)

