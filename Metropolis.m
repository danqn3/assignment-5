classdef Metropolis
    properties
        logTarget, initialState, samples, proposalStd
    end
    
    methods (Access = private)
        function yesno = accept(self, proposal)
            alpha = exp(self.logTarget(proposal) - self.logTarget(self.initialState));
            if rand < alpha
                self.initialState = proposal;
                yesno = true;
            else
                yesno = false;
            end
        end
    end  

    methods
        function obj = Metropolis(logTarget, initialState)
            obj.logTarget = logTarget;
            obj.initialState = initialState;
        end
        
        function self = sample(self, n)
            samples = zeros(n, 1);
            current = self.initialState;
            for i = 1:n
                proposal = normrnd(current, self.proposalStd);
                if self.accept(proposal)
                    current = proposal;
                end
                samples(i) = current;
            end
            self.initialState = current;
            self.samples = samples;
        end

        function self = adapt(self, blockLengths)
            sigma = 1;
            acceptance_target = 0.4;
        
            for i = 1:length(blockLengths)
                current_state = self.initialState;
                num_proposals = blockLengths(i);
                proposals = arrayfun(@(x) normrnd(x, sigma), repmat(current_state, num_proposals, 1));
                acceptance_probs = min(1, exp(self.logTarget(proposals) - self.logTarget(current_state)));
                acceptance_rate = sum(rand(num_proposals, 1) < acceptance_probs) / num_proposals;
                if acceptance_rate < acceptance_target
                    sigma = sigma * 0.9;
                else
                    sigma = sigma * 1.1;
                end
                self.proposalStd = sigma;
                self.initialState = proposals(end);
            end
        end

        function summ = summary(self)
            sortedSamples = sort(self.samples);
            m = mean(sortedSamples);
            ci = [sortedSamples(round(0.025 * length(sortedSamples))), sortedSamples(round(0.975 * length(sortedSamples)))];
            summ.mean = m;
            summ.c025 = ci(1);
            summ.c975 = ci(2);
        end
    end
end
