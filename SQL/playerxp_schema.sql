CREATE TABLE `erro_playerxp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `command` int(11) NOT NULL DEFAULT '0',
  `security` int(11) NOT NULL DEFAULT '0',
  `medical` int(11) NOT NULL DEFAULT '0',
  `science` int(11) NOT NULL DEFAULT '0',
  `engineering` int(11) NOT NULL DEFAULT '0',
  `civilian` int(11) NOT NULL DEFAULT '0',
  `cargo` int(11) NOT NULL DEFAULT '0',
  `silicon` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;
