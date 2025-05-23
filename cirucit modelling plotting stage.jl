using DataFrames
using Plots
using NativeFileDialog
using CSV
using DataInterpolations
using DelimitedFiles
plotly()


function plot_default()
    plot(dpi=360,framestyle=:box,
    right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,top_margin=5*Plots.mm,
    legend=false)
end

function sort_files()
    fl=pick_folder()
    files_vector=[]
    F=[]
    for file in readdir(fl,join=true)
            if split(basename(file),".")[end]=="txt" || split(basename(file),".")[end]=="html"
                continue
            else
                push!(files_vector,file)
            end
        end
    print(files_vector)

    permutation_file=pick_file()
    permutation_vector=Int.(readdlm(permutation_file, ' '))
    print(permutation_vector)
    final_files=files_vector[permutation_vector]

    for file in final_files
        df=CSV.read(file,DataFrame)
        push!(F,df)
    end
    return F
end

function plotting_stage()
    plot_Nyquist=plot_default()
    plot_Bode=plot_default()
    plot_Module=plot_default()

    dfs=sort_files()

    for df in dfs
        idx=df."-Z'' (Ω)".>0
        Frequency=df."Frequency (Hz)"[idx]
        Zre=df."Z' (Ω)"[idx]
        Zimg=df."-Z'' (Ω)"[idx]
        Z=df."Z (Ω)"[idx]
        Phase=df."-Phase (°)"[idx]

        plot_Nyquist=plot!(plot_Nyquist,Zre,Zimg,
        #=labels=l[i],=#marker=:circle,legend=true,xlabel="Zre (Ω)",ylabel="Zimg (Ω)")
        display(plot_Nyquist)
    end
end

function singular_plot()
    fl=pick_file()
    df=CSV.read(fl,DataFrame)
    x_f=[]
    M=[]
    I=[]
    m=[]
    I_m=[]
    inter=[]
    index_inter=[]
    min=[]
    
    #plot_Nyquist=plot_default()
    #plot_Bode=plot_default()
    #plot_Module=plot_default()

    idx=(df."-Z'' (Ω)" .<= 1000) .& (df."-Z'' (Ω)" .>0) 
    #idx=df."-Z'' (Ω)" .>0
    Frequency=df."Frequency (Hz)"[idx]
    Zre=df."Z' (Ω)"[idx]
    Zimg=df."-Z'' (Ω)"[idx]
    Z=df."Z (Ω)"[idx]
    Phase=df."-Phase (°)"[idx]

    x_intp=df."Z' (Ω)"[idx]
    #deleteat!(x_intp,31)
    x1=sortperm(x_intp)
    y_intp=df."-Z'' (Ω)"[idx]
    #deleteat!(y_intp,31)
    f=sortperm(Frequency)
    f_intp=df."Frequency (Hz)"[idx]
    #f_intp=Frequency
    phase_intp=df."-Phase (°)"[idx]

    A=CubicSpline(y_intp[x1],x_intp[x1])
    B=CubicSpline(phase_intp[f],f_intp[f])

    g=collect(eachindex(f))
    @show g
    @show f_intp
    @show f

    p_linear_intp=plot(range(first(x_intp),last(x_intp),length=50000),x->A(x) ,legend=false,aspect_ratio=1)
    x_c=collect(range(first(x_intp),last(x_intp),length=50000))
    y_c=A(x_c)

    p_freq_linear_intp=plot((range(first(f_intp),last(f_intp),length=50000)),x->B(x),legend=false)
    x_f=collect(range(first(f_intp),last(f_intp),length=50000))
    y_f=B(x_f)

    #@show x_f
    #@show y_f
    
    

    for i in 2:(length(y_c)-1)
        if(y_c[i-1]<y_c[i]>y_c[i+1])
            push!(M,y_c[i])
            push!(I,i)
        end
        if(y_c[i-1]>y_c[i]<y_c[i+1])
            push!(m,y_c[i])
            push!(I_m,i)
        end
    end

    println(first(x_intp),"\n",last(x_intp))

    println(M)
    println(I)
    println(m)
    println(I_m)
    #println(idx)
    tangent=(M.-y_c[1])./(x_c[I].-x_c[1])
    phi=rad2deg.(atan.(tangent))
    println(tangent)
    @show phi
    fs=pick_folder()
    #p_phase=plot(Frequency,Phase,xscale=:log10)
    #savefig(p_phase,joinpath(fs,basename(fl)*"_Bode Phase"))
    savefig(p_freq_linear_intp,joinpath(fs,basename(fl)*"_Phase_intp.html"))

    @show M
    @show I

    plot(Zre,Zimg)
    
    fas=scatter!(x_c[I],M)
    display(fas)

    line_45= (x_c .- x_c[1]) .*tangent .+ y_c[1]

    #p=plot(plot_Nyquist,Zre,Zimg, xlims=[100,115],ylims=[0,30])
    p2=plot!(p_linear_intp,x_c,line_45)
    display(p_linear_intp)
    #p=plot!(Zre,Zimg, xlims=[100,115],ylims=[0,30])
    
    savefig(p2,joinpath(fs,basename(fl)*"_Nyquist_line1.html"))
    #print(line_45)

    #=for j in eachindex(y_c)
        if isapprox(y_c[j] .-line_45[j], 0, atol=0.1)
        push!(inter,y_c[j].-line_45[j])
        push!(index_inter,j)
        push!(min,y_c[j])
        end
    end


    @show inter
    @show index_inter
    @show min
    #@show inter=#

    #println(y_c[I].-y_c[1])
    #print(x_c[I].-x_c[1])\
    zero_crossings_y=[]
    zero_crossings_x=[]
    zero_crossings_f=[]

    splot=plot(x_c ,y_c .- line_45)
    display(splot)

    for k in eachindex(x_c[1:end-1])
        if (y_c .- line_45)[k] .* (y_c .- line_45)[k+1] .<=0
            push!(zero_crossings_y,y_c[k])
            push!(zero_crossings_x,x_c[k])
            push!(zero_crossings_f,x_f[k])
            #frequency extrapol
        end
    end
     
    @show zero_crossings_y
    @show zero_crossings_x
    @show zero_crossings_f

    #scatter!(splot,zero_crossings_x,zeros(length(zero_crossings_x)))
    scatter!(p2,zero_crossings_x,zero_crossings_y,hover=zero_crossings_f)
end


singular_plot()
plotting_stage()

sort_files()
    
    