using Plots
using DataFrames
using CSV
using NativeFileDialog
plotly()

function formula_parallel(R1,C1,R2,C2)
    teta1=R1*C1 
    teta2=R2*C2 
    #f=[0.01:0.01:20;21:2:2000;2001:50:100001]
    #f_fs=reverse(f)

    F=pick_file()
    df=CSV.read(F,DataFrame)
    f=df."Frequency (Hz)"
    Zre_data=df."Z' (Ω)"
    Zimg_data=df."-Z'' (Ω)"
    
    f_test=[300001:100:700000;f;]

    ratio = teta2/teta1
    @show ratio

    Zre_zero=(R1 ./(1 .+ (2*π .*f_test[1] .* R1*C1).^2))

    Zre=  (R1 ./(1 .+ (2*π .*f_test .* R1*C1).^2)) .- Zre_zero # .+ R2 ./(1 .+ (2*π*f_fs*R2*C2).^2)

    Zimg= (2*π .*f_test .* (R1 .^2) * C1) ./ (1 .+ (2*π.*f_test .*R1 * C1).^2)  #.+ 
    #(2*π*f_fs.*(R2.^2) * C2) ./ (1 .+ (2*π*f_fs*R2 * C2).^2)

    phase=rad2deg.(atan.(Zimg,Zre))

    #@show f_fs
    @show first(Zimg),last(Zimg)
    @show first(Zre),last(Zre)
    scatter(Zre,Zimg)
    
    #scatter(f_fs,phase,xscale=:log10,legend=false)
    @show rad2deg(atan(last(Zimg)/last(Zre)))
    @show rad2deg(atan(first(Zimg)/first(Zre)))
    plot(Zre,Zimg)
   # @show first(f)
    #plot(f_test,phase,xscale=:log10,legend=false)
    
end

    
formula_parallel(10,0.000001,1000,0.00001)
    

