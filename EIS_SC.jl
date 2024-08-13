using Plots 
using CSV
using DataFrames
using NativeFileDialog
using Colors
using ColorSchemes
plotlyjs()

function plot_Nyquist()
plot(seriestype=:scatter,dpi=360,
title="Nyquist",xlabel="Zre (Ω)",ylabel="Zimg (Ω)",
right_margin=7*Plots.mm,framestyle=:box,
linewidth=2, formatter=:plain,leg=false,size=(500,500),
markersize=3, top_margin=5*Plots.mm)
end

function plot_Bode()
    plot(dpi=360,xscale=:log10,title="Bode",
    xlabel="Frequency (Hz)",ylabel="Phase Difference (deg)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain, xticks=10.0 .^(-2:5),leg=false,
    top_margin=5*Plots.mm)
end

function plot_Module()
    plot(dpi=360,xscale=:log10,
    xlabel="Frequency (Hz)",ylabel="Z (Ω)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain, xticks=10.0 .^(-2:5),leg=false,
    top_margin=5*Plots.mm)
end

function skip_html(file)
    fas=split(basename(file),".")
    if fas[end]=="html"
        return true
    else 
        return false
    end
end

function pick_type_multiple_EIS()
    Fs=pick_folder()
    f=[]
    l=["1","2","3","4","5","6","7","8","9"]
    for file in readdir(Fs,join=true)
        if skip_html(file) 
            @info "skipping $file"
            continue
        end
        df=CSV.read(file,DataFrame)
        push!(f,df)
    end
    p_N=plot_Nyquist()
    p_B=plot_Bode()
    p_M=plot_Module()
    for i in eachindex(f)
        df=f[i]
        idx=df."-Z'' (Ω)".>0
        x_N=df."Z' (Ω)"[idx]
        y_N=df."-Z'' (Ω)"[idx]

        x_B=df."Frequency (Hz)"[idx]
        y_B=df."-Phase (°)"[idx]

        x_M=df."Frequency (Hz)"[idx]
        y_M=df."Z (Ω)"[idx]

        p_N=plot!(p_N,x_N,y_N,color_palette=palette(:BuPu,9,rev=true),
            labels=l[i],linewidth=3,marker=:circle,legend=true)
        
        p_B=plot!(p_B,x_B,y_B,color_palette=palette(:BuPu,9,rev=true),
            labels=l[i],linewidth=3,xscale=:log10,legend=true)
        
        p_M=plot!(p_M,x_M,y_M,color_palette=palette(:BuPu,9,rev=true),
            labels=l[i],linewidth=3,yscale=:log10,xscale=:log10,legend=true)
    end
    c=(pick_folder())
    savefig(p_N,joinpath(c,basename(Fs)*"_Nyquist.html"))
    savefig(p_B,joinpath(c,basename(Fs)*"_Bode.html"))
    savefig(p_M,joinpath(c,basename(Fs)*"_Module.html"))
end

pick_type_multiple_EIS()

h=pick_file()
df=CSV.read(h,DataFrame)
print(df)
linear_bmw_5_95_c86_n256
linear_worb_100_25_c53_n256
fuchsia
candy
dracula
diverging_tritanopic_cwr_75_98_c20_n256

RdPu
BuPu