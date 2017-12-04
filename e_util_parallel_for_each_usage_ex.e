  Usage example of the Parallel For Each
  
  specman -c 'load parallel_for_each/e_util_parallel_for_each_usage_ex.e; test'

  
  The env unit contains a list of agent. 
  
  It run in parallel a TCM of the agents.

  
<'

import e_util_parallel_for_each.e;

unit agent {      
  
    my_method() @sys.any is {
        message(LOW, "my_method() being called");
        var wait_cycles : int;
        gen wait_cycles keeping {it in [10..100]};
        wait [wait_cycles] * cycle;
        message(LOW, "my_method() ends");
    };    

    // Use macro #1 - wrap the required method
    wrap_for_parallel my_method;
    
};



unit env {
    agents : list of agent is instance;
    keep agents.size() is in [3..7];

        
    scenario() @sys.any is {
        raise_objection(TEST_DONE);
        
        // Use macro #2 - run in parallel
        for_each_in_parallel agents agent my_method;        
        out();
        message(LOW, " ====== All agents are done \n");
        
        
        wait [10] * cycle;
        drop_objection(TEST_DONE);
    };
    run() is also {
        start scenario();
    };
};

extend sys {
    env : env is instance;
};

'>




