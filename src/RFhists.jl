function RFhists(trialdata, unit)
    #isolate unit data
    cnames = names(trialdata)
    nn=0
    for ii in 1:length(cnames)
        i=ii
        global i
        if occursin("spike", string(cnames[ii]))
            nn+=0.5
        end
        if nn >= unit
            break
        end
    end
    utimes = i-1
    uwaves = i

    #
    typs = unique(trialdata.names)

    #get psth of each trial type left
    figure()
    PyPlot.title(typs)
    for tt in typs
        td = trialdata[trialdata.names .== tt,:]

        vals=[]

        for ii in 1 : size(td,1)
            tmp = td[ii,utimes] .- td.evnts[ii][1] .- 0.2 #startTime is one segment off
            push!(vals, collect(skipmissing(tmp)))
        end
        spikes=[]
        for ii in vals, jj in ii
            push!(spikes,jj)
        end

        #plot psth
        #figure()
        plt.hist(spikes, length(0:0.01:3))
        #PyPlot.title("$(unique(td.names))")

    end
    for ii in [0.05, 0.35, 0.65, 0.95, 1.25, 1.55]
        plot([ii, ii], [0, 10], color="green")
        plot([ii+0.1, ii+0.1], [0, 10], color="red")
    end

end
