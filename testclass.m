%import constants.*;
classdef testclass < handle
	properties (Access=private)
		x = 1;
		y = pi;
	end

	properties (Dependent)
      JobTitle
   end 

   properties %(Transient)
      OfficeNumber
   end 

   properties (SetAccess = protected, GetAccess = public)
      EmpNumber
      z = 10;
   end 


   methods
   	  function obj = testclass(x)
   	  	% obj.x.addnumber();
        obj.x = x;
   	  end
      function Eobj = Employee(name)
         % Method help here
            Eobj.Name = name;
            Eobj.EmpNumber = employee.getEmpNumber;
      end

      function result = backgroundCheck(obj)
         result = queryGovDB(obj.Name,obj.SSNumber);
           if result == false
              notify(obj,'BackgroundAlert');
           end
      end

      function x = getx(obj)
        disp('x');
        x = obj.x;
      end

      function jobt = get.JobTitle(obj)
         %jobt = currentJT(obj.EmpNumber);
         jobt = 0;
         disp('get.JobTitle(obj)');
      end

      % function set.OfficeNumber(obj,setvalue)
      %    if isInUse(setvalue)
      %       error('Not available')
      %    else
      %       obj.OfficeNumber = setvalue;
      %    end
      % end

     %  function set.EmpNumber(obj,value)
     %  	obj.EmpNumber  = value;
     %  end

      function EmpNumber = get.EmpNumber(obj)
       	EmpNumber = obj.EmpNumber;
  	  end

      function addz(obj,v)
      	obj.z = obj.z + v;
      end

      function z = getz(obj)
      	z = obj.z;
      end

      %% get.z: function description
      function z = get.z(obj)
      	z = obj.z;
        disp ('get.z(obj)');
      end
      


   end

   methods (Static)
      function num = getEmpNumber
         num = queryDB('LastEmpNumber') + 1;
      end
   end
end