File name     : e_util_parallel_for_each.e
Title         : Parallel For-Each
Project       : Utilities examples
Created       : 2017
              :
Description   : Call in parallel multiple instances of same TCM, when the 
              : number of instances is unknown and the execution of all TCMs
              : is blocking; the called TCM will continue only after all TCMs 
              : are done.
              :  
              :
              : Usage:
              :
              :   1) Wrap the method that is to be called, with this macro:
              :
              :      wrap_for_parallel <method name>
              : 
              :      for example :
              : 
              :      wrap_for_parallel prepare_data;
              :
              :   2) Call the method, with this macro:
              :
              :      for_each_in_parallel <field name (a list)> <field type> <method name> 
              : 
              :      for example :
              :
              :      for_each_in_parallel agents agent prepare_data;
              :
Notes         : 
              : Ideas for enhancements:
              :
              :     - wrap_for_parallel macro can check if a wrapper already created 
              :       for this method.
              :       For this, the macro should be a Define As Computed.
              :
              :    - for_each_in_parallel macro can be modified so will accept as a
              :      parameter the field name, and get the field type using typeof_item()
              :
              :      Also can be extended to get parameters to be passed to the called
              :      method.
              :
Prerequisites :  Specman 15.2 (or newer)
              :
Example       : See usage example e_util_parallel_for_each_usage_ex.e 
              :
        
   specman -c 'load parallel_for_each/e_util_parallel_for_each_usage_ex.e; test'

--------------------------------------------------------------------------- 
  
  
<'

define <e_util_wrap_for_parallel_for_each'struct_member> "wrap_for_parallel <method'name>" as {
    static <method'name>_execution_ctr : int = 0;

    static event <method'name>_finished;
    
    static <method'name>_increase () is {
        <method'name>_execution_ctr += 1;
        assert <method'name>_execution_ctr >= 0;
    };
    static <method'name>_decrease () is {
        <method'name>_execution_ctr -= 1;
        assert <method'name>_execution_ctr >= 0;
        if <method'name>_execution_ctr == 0 {
            emit <method'name>_finished;
        };
    };
    
    static <method'name>_get_ctr() : int is {
        result = <method'name>_execution_ctr;
    };
        
        
    <method'name>_wrap () @sys.any is {
        <method'name>_increase();
        <method'name>();
        <method'name>_decrease();
    };    
};



 

define <e_util_run_in_parallel_for_each'action> "for_each_in_parallel <field_name'name> <field_type'name> <method_name'name>" as {
    
    // Prevent multiple entrance (for same method)
    assert <field_type'name>::<method_name'name>_get_ctr() == 0 else
      error("Calling for_each_in_parallel of a method while previous parallel execution of ",
            "same method was not finished, is not supported");
    
    for each in <field_name'name> {
        start it.<method_name'name>_wrap();
    };
    
    message(HIGH, "started them all");
    sync cycle;
    sync @<field_type'name>::<method_name'name>_finished;
};



'>
  
