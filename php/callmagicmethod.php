<?php

class Str
{
	private $s = '';

	private $functions = [
		'length' => 'strlen',
		'upper' => 'strtoupper',
		'lower' => 'strtolower'
		// map more method to functions
	];

	public function __construct(string $s)
	{
		$this->s = $s;
	}

	public function __call($method, $args)
	{
		if (!in_array($method, array_keys($this->functions))) {
			throw new BadMethodCallException();
		}

		array_unshift($args, $this->s);

		return call_user_func_array($this->functions[$method], $args);
	}
}

$s = new Str('Hello, World!');

echo $s->upper() . '<br>'; // HELLO, WORLD!
echo $s->lower() . '<br>'; // hello, world!
echo $s->length() . '<br>'; // 13
