Script to enable and disable charger on fortuna3g.

#### Requirements : 
Enable the necessary i2c bus.
The following needs to be added to device tree :
```
&blsp_i2c6 {
	status = "okay";
};
```

#### Usage
`./toggle-charger.sh on`  
`./toggle-charger.sh off`  
`./toggle-charger.sh auto`  
  
The auto parameter turns on the charger if battery percentage is below 40% and disables the charger if battery percentage is above 75%
