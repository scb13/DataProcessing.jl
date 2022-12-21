function addPL2!(trialdata, neuron, pl2, path="Y:\\Aristotle\\MT Units")
    #get event times from pl2, spikes from neurons, and behavior from trialdata
    cd(path) ####change to variable to input path ###
    #load event channels
    strobed_input = PL2.load_channel(pl2, "strobed", scale = true)
    do1 = PL2.load_channel(pl2, "evt03", scale = true)
    do2 = PL2.load_channel(pl2, "evt04", scale = true)#
    do3 = PL2.load_channel(pl2, "evt05", scale = true)#
    do4 = PL2.load_channel(pl2, "evt06", scale = true)
    do5 = PL2.load_channel(pl2, "evt07", scale = true)
    do6 = PL2.load_channel(pl2, "evt08", scale = true)
    do7 = PL2.load_channel(pl2, "evt09", scale = true)
    #turn strobe into one giant string
    allstb = String(convert.(UInt8, strobed_input[:strobed]));
    #load neurons from sort
    @load "$(neuron)" neurons
    neurons = convert.(AbstractNeuron, neurons)
    u = length(neurons)
    #stimes = spike_indices(neurons[1])/40000 #40 kHz
    #chop up strobe string into names
    if '\x04' in allstb #indicates abnormal strobe function, fixable
        #use start and stop event pulses to find dropped or saved files, cannot use strobe save file names
        #dout5 for dt, st, and main marks start of fix and failsafe save
        #rf needs to go to end to save

        #use timing of \x02 timing to make sure dout5 happens before next \x02 (unless rf)

        #evt01 is the start and stop pulse, make sure 2 pulses occur for each \x02, make sure timing of it works, strobe follows start so there should be two pulse between each, one indiciates trial abort, double check
        #in strobe, \x03 is trial ended, \x05 is reward delivered, \x06 is data saved (\x0E and \x0F are lost fix or abort for other reasons)

        #went with start and save characters
        ss=0
        vv=0
        gg=0
        startndx = Vector{Real}(undef, 0)
        savedndx = Vector{Real}(undef, 0)
        gapndx = Vector{Real}(undef, 0)
        for ii in 1:length(allstb)
            if allstb[ii] == '\x02'
                ss+=1
                push!(startndx, ii)
            end
            if allstb[ii] == '\x06'
                vv+=1
                push!(savedndx, ii)
            end
            if allstb[ii] == '\0' || allstb[ii] == '\x04'
                gg+=1
                push!(gapndx, ii)
            end
        end

        #save those names, lengths still accurate even if identiy is off by 4
        nms = Vector{AbstractString}(undef, 0)
        savename = Vector{AbstractString}(undef,0)
        for ii in 1:length(startndx)
            ndx = findfirst(gapndx.>startndx[ii])
            push!(nms, allstb[startndx[ii]+1:gapndx[ndx]-1])
            push!(savename, allstb[gapndx[ndx]+1:gapndx[ndx+1]-1])
        end

        #find dropped trials
        sv = Vector{Real}(undef, 0)
        drp = Vector{Real}(undef, 0)
        vv=1
        for ii = 1:length(startndx)-1
            if startndx[ii] < savedndx[vv] && startndx[ii+1] > savedndx[vv] #if a start pulse is before a save pulse and the next start pulse is after than save pulse
                push!(sv, ii);
                if vv==length(savedndx) #once last saved trial has happened, cut off all other fails
                    break
                end
                vv+=1
            else
                push!(drp, ii);
            end
        end
        if vv==length(savedndx)#if one more saved trial
            if startndx[end] < savedndx[vv] #if last trial start was saved
                push!(sv, length(startndx));
            else
                push!(drp, length(startndx));
            end
        end
        #now find first trial in partcular behavior table using name length to differentiate blocks
        tmp=[]
        for ii in 1:length(nms)
            push!(tmp, length(nms[ii]))
        end
        mk = length(trialdata.names[1])

        ndx = findfirst(mk .== tmp)
        keptnms = nms[sv[findfirst(sv .>= ndx):end]] #greater or equal in case first nms was not in sv
        starts = do1[:timestamps][sv[findfirst(sv .>= ndx):end]]
        evnts = Array{Any}(undef, 0)

    else #no strobe failure
        ss=0
        gg=0
        startndx = Vector{Real}(undef, 0)
        gapndx = Vector{Real}(undef,0)
        for ii in 1:length(allstb)
            if allstb[ii] == '\x02'
                ss+=1
                push!(startndx, ii)
            end
            if allstb[ii] == '\0'
                gg+=1
                push!(gapndx, ii)
            end
        end
        #save those names
        nms = Vector{AbstractString}(undef, 0)
        savename = Vector{AbstractString}(undef,0)
        Nfile = Vector{Int}(undef, 0)
        for ii in 1:length(startndx)
            ndx = findfirst(gapndx.>startndx[ii])
            push!(nms, allstb[startndx[ii]+1:gapndx[ndx]-1])
            push!(savename, allstb[gapndx[ndx]+1:gapndx[ndx+1]-1])
            push!(Nfile, parse(Int,savename[ii][end-3:end]))
        end
        #find dropped trials
        sv = Vector{Real}(undef, 0)
        drp = Vector{Real}(undef, 0)
        for ii = 2:length(Nfile)
            if Nfile[ii-1] == Nfile[ii]
                push!(drp, ii-1)
            elseif ii>500 && Nfile[ii]<Nfile[ii-1] && sum(Nfile[ii:end].==Nfile[ii-1])==1 #if switched to new block without finishing last trial
                push!(drp, ii-1)
            else
                push!(sv, ii-1)
            end
        end
        #make sure last trial was saved, otherwise drop it
        if length(do1[:timestamps]).==length(Nfile)
            push!(sv, length(Nfile));
        else
            push!(drp, length(Nfile))
        end

        if length(strobed_input[:timestamps][startndx]) != length(startndx)
            println(length(strobed_input[:timestamps][startndx]), ' ', length(startndx)) #if not the same break function
            return
        end
        # assign times, waves, and events to trials
        ndx = findfirst(trialdata.names[1] .== nms)
        keptnms = nms[sv[findfirst(sv .>= ndx):end]] #greater or equal in case first nms was not in sv
        starts = do1[:timestamps][sv[findfirst(sv .>= ndx):end]]
        evnts = Array{Any}(undef, 0)
    end
    #    println(nms)
    #if still out of sync, likely from same type of trial from st started main set, only works if strobe good, luckily above catches days when it didn't so this unneeded
    if ((keptnms[2] != trialdata.names[2]) || (keptnms[3] != trialdata.names[3])) && (length(trialdata.names) != length(keptnms)) && ~('\x04' in allstb)
        ceil = findfirst( x -> occursin("30", x), keptnms) #30 for 30% coherence
        ndx = findlast(trialdata.names[1] .== keptnms[1:ceil])
        keptnms=keptnms[ndx:end]
    end
    #add conditional to continue if blocks out of order (ie keptnms and trialdata wildly different lengths)
    if length(trialdata.names) != length(keptnms)
        if length(trialdata.names)>=1000
            #if experiment ends up here its because maestro dropped a trial and otherwise not appropriate to be here
        else
            tmp=[]
            for ii in 1:length(keptnms)
                push!(tmp, length(keptnms[ii]))
            end
            mk = length(trialdata.names[1])
            if mk<10 #if looking at receptive fields, below code won't isolate them so do nothing at this time
            elseif mk == 16 || mk == 15 #dt or speed pulse
                mklow = mk
                mkhi = mk
                subndx = findall(mklow.<=tmp.<=mkhi)
                keptnms = keptnms[subndx]
                starts = starts[subndx]
            elseif mk < 15 #no pulse and variable speed
                mklow = mk-1
                mkhi = mk+1 #if repeated blocks have different speed it could be higher or lower by one from first random trial
                subndx = findall(mklow.<=tmp.<=mkhi)
                keptnms = keptnms[subndx]
                starts = starts[subndx]
            end
        end
    end
    #        println(keptnms)
    dsable = true
    for ii in 1:size(trialdata,1)
        #add conditional to continue if blocks out of order (ie keptnms and trialdata wildly different lengths)
        if '\x04' in allstb && ii == 1 #indicates abnormal strobe function, fixable
            println("Correcting for strobe pin failure")
            dsable = false
        elseif keptnms[ii] != trialdata.names[ii] && dsable
            println("ERROR in data syncing! $ii")
            break
        end
        lngth = size(trialdata.Hpos[ii],1)/1000
        #push!(spiketimes, stimes[starts[ii] .< stimes .< starts[ii]+lngth])
        #push!(spikewaves, neurons[1][:template])

        e1 = starts[ii]
        if ~isnothing(do2)
            e2 = do2[:timestamps][e1 .< do2[:timestamps] .< e1+lngth]
        else
            e2=[]
        end
        if ~isnothing(do3)
            e3 = do3[:timestamps][e1 .< do3[:timestamps] .< e1+lngth]
        else
            e3=[]
        end
        if ~isnothing(do4)
            e4 = do4[:timestamps][e1 .< do4[:timestamps] .< e1+lngth] #busted in rig for 2019, fixed 2021
        else
            e4=[]
        end
        if ~isnothing(do5)
            e5 = do5[:timestamps][e1 .< do5[:timestamps] .< e1+lngth]
        else
            e5=[]
        end
        if ~isnothing(do6)
            e6 = do6[:timestamps][e1 .< do6[:timestamps] .< e1+lngth]
        else
            e6=[]
        end
        if ~isnothing(do7)
            e7 = do7[:timestamps][e1 .< do7[:timestamps] .< e1+lngth]
        else
            e7=[]
        end
        push!(evnts, [e1,e2,e3,e4,e5,e6,e7])
        #        println(ii)        println([e1,e2,e3,e4,e5,e6,e7])
        #
    end
    trialdata.evnts = evnts
    #loop through units and add them to trials
    for uu in 1:u
        stimes = spike_indices(neurons[uu])/40000 #40 kHz
        spiketimes = Array{Array}(undef,0)
        spikewaves = Array{Any}(undef, 0)
        for ii in 1:size(trialdata,1)
            lngth = size(trialdata.Hpos[ii],1)/1000
            push!(spiketimes, stimes[starts[ii] .< stimes .< starts[ii]+lngth])
            push!(spikewaves, neurons[uu][:template])
        end
        if u==1
            #if only one unit no underscores
            trialdata.spiketimes = spiketimes
            trialdata.spikewaves = spikewaves;
        else
            trialdata[:,Symbol("spiketimes_$uu")] = spiketimes
            trialdata[:,Symbol("spikewaves_$uu")] = spikewaves;
        end
    end
end
