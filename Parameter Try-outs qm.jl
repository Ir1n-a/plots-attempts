using Plots
plotly()

function formula_parallel(R1,C1,R2,C2)
    teta1=R1*C1 
    teta2=R2*C2 
    f=[0.01:0.01:10;11:2:2000;2001:50:100001]
    f_fs=reverse(f)

    ratio = teta2/teta1
    @show ratio

    Zre= (R1 ./(1 .+ (2*π*f_fs*R1*C1).^2))  .+ R2 ./(1 .+ (2*π*f_fs*R2*C2).^2)

    Zimg= (2*π*f_fs.*(R1 .^2) * C1) ./ (1 .+ (2*π*f_fs*R1 * C1).^2)  .+ 
    (2*π*f_fs.*(R2.^2) * C2) ./ (1 .+ (2*π*f_fs*R2 * C2).^2)

    #@show f_fs
    @show first(Zimg),last(Zimg)
    @show first(Zre),last(Zre)
    scatter(Zre,Zimg,hover=f_fs)
end

    
formula_parallel(1000,0.00001,5000,0.0001)
    


