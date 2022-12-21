

function testCharacterization(filedate)
    neurons = load_neurons("neurons$(filedate).jld2")
    println(length(neurons))
    plot_templates(neurons, neighbors=true); plot_rate_vs_time(neurons)
    trialdata = readbevdata("$(filedate)dt")
    addPL2!(trialdata, "neurons$(filedate).jld2","$(filedate).pl2","Y:\\...")
    for ii in 1:length(neurons)
        directiontuning(trialdata,ii)
    end
    trialdata = readbevdata("$(filedate)rf")
    addPL2!(trialdata, "neurons$(filedate).jld2","$(filedate).pl2","Y:\\...")
    for ii in 1:length(neurons)
        RFhists(trialdata,ii)
        RFfield(trialdata,ii)
    end
    trialdata = readbevdata("$(filedate)st")
    addPL2!(trialdata, "neurons$(filedate).jld2","$(filedate).pl2","Y:\\...")
    for ii in 1:length(neurons)
        FRatPSforpl(trialdata,ii)
    end
end
