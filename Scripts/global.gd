extends Node

func smooth_exp(a: float, b: float, delay: float, delta: float) -> float:
	return lerp(a, b, 1.0 - exp(-delay * delta))
	
func smooth_exp_angle(a: float, b: float, delay: float, delta: float) -> float:
	return lerp_angle(a, b, 1.0 - exp(-delay * delta))
	
func smooth_pow(a: float, b: float, rate: float, delta: float) -> float:
	return lerp(a, b, 1.0 - pow(rate, delta))
	
func smooth_pow_angle(a: float, b: float, rate: float, delta: float) -> float:
	return lerp_angle(a, b, 1.0 - pow(rate, delta))
