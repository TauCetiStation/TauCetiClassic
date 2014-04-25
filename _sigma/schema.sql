CREATE TABLE `global_whitelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `inviter` varchar(32) NOT NULL,
  `rank` int(2) NOT NULL,
  `invites` int(2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 ;