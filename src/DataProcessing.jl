module DataProcessing

    using NeurophysToolbox, SpikeSorting, JLD2

# takes in recording files to save and sort, outputing sorted neurons to be
    #manually confirmed (functions included)

    savedates = []
    for ii in 1:length(savedates)
        println(savedates[ii])
        # single and tetrodes
        recording = PL2Recording("$(savedates[ii]).pl2")
        neurons = spike_sort(AllNeighborsProbe(recording), verbose=false, segment_duration=nothing, binary_pursuit=true);
        NeurophysToolbox.save_neurons("bulkneurons$(savedates[ii]).jld2", neurons)
        plot_neuron_summary(neurons)
        #=
        #plexon s probes
        x_pos = repeat([0,50],8)
        y_pos = [Integer(floor(i/2))*100 for i in range(0, length=16)]
        recording = PL2Recording("$(savedates[ii]).pl2")
        export_binary_file(recording, "$(savedates[ii]).bin")
        neurons = spike_sort(XYProbe(x_pos,y_pos,200,recording), verbose=true, segment_duration=nothing, binary_pursuit=false);
        NeurophysToolbox.save_neurons("bulkneurons$(savedates[ii]).jld2", neurons)
        plot_neuron_summary(neurons)
        =#
    end
    #after manual sort use:
    #NeurophysToolbox.load_neurons("bulkneurons$(savedates[ii]).jld2",neurons) #if reloading
    #deleteat!(neurons, <index>)
    #NeurophysToolbox.save_neurons("neurons$(savedates[ii]).jld2", neurons)
    #characterize
    #testCharacterization(<filedate>)

# after alignment, take in data tables and perform necessary computations to pair
    #down to manageable size and construct sim pop
        ###seperate function?
        
end
