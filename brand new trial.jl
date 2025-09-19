using DataFrames
using CSV
using NativeFileDialog
using Plots

function import_files()
    println("pick folder of frequency data")
    fldr=pick_folder()
    freq_files=[]


    println("pick file of EIS data")
    file_EIS=pick_file()

    max_current=[]
    specific_freq=[]

    vector_sorted_freq=[]

    df_EIS=CSV.read(file_EIS,DataFrame)
    idx=df_EIS."-Z'' (Ω)" .<0
    Frequencies=df_EIS."Frequency (Hz)"
    removed_frequencies=Frequencies[idx]

    for file in readdir(fldr,join=true)

        file_ext=split(basename(file),".")
        
        if file_ext[end] =="txt"
            df=CSV.read(file,DataFrame)
            if df."Frequency (Hz)"[1] ∉ removed_frequencies
                push!(freq_files,df)
            end
        end
    end

    for i in eachindex(freq_files)
        df=freq_files[i]

        current=maximum(df."Current (AC) (A)")
        freq=first(df."Frequency (Hz)")

        push!(max_current,current)
        push!(specific_freq,freq)
    end

    sorted_freq=sortperm(specific_freq)

    @show max_current
    @show specific_freq
    @show sorted_freq

    @show specific_freq[sorted_freq]

    issorted(specific_freq[sorted_freq])

    final_freq=specific_freq[sorted_freq]
    final_current=max_current[sorted_freq]

    @show final_freq
    @show final_current
    @show removed_frequencies

    #issorted(final_current)


    scatter(final_freq,final_current)

    #@show freq_files
end

import_files()