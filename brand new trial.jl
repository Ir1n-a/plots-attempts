using DataFrames
using CSV
using NativeFileDialog
using Plots

function import_files()
    fldr=pick_folder()
    freq_files=[]

    max_current=[]
    specific_freq=[]

    for file in readdir(fldr,join=true)

        file_ext=split(basename(file),".")
        
        if file_ext[end] =="txt"
            df=CSV.read(file,DataFrame)
            push!(freq_files,df)
        end
    end

    for i in eachindex(freq_files)
        df=freq_files[i]

        current=maximum(df."Current (AC) (A)")
        freq=first(df."Frequency (Hz)")

        push!(max_current,current)
        push!(specific_freq,freq)
    end

    @show max_current
    @show specific_freq

    #@show freq_files
end

import_files()