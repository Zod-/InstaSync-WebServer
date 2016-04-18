SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

CREATE TABLE IF NOT EXISTS `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(45) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `room_name` varchar(16) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `username` varchar(16) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `loggedin` tinyint(1) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `room_name` (`room_name`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `friends_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userA` int(11) NOT NULL,
  `userB` int(11) NOT NULL,
  `sentBy` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `userA` (`userA`,`userB`),
  KEY `sentBy` (`sentBy`),
  KEY `userB` (`userB`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `friend_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `to_id` int(11) NOT NULL,
  `from_id` int(11) NOT NULL,
  `message` varchar(240) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `viewed` tinyint(1) NOT NULL,
  `sent` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `to` (`to_id`,`from_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `friend_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userA` int(11) NOT NULL,
  `userB` int(11) NOT NULL,
  `sentBy` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `userA` (`userA`,`userB`),
  KEY `sentBy` (`sentBy`),
  KEY `userB` (`userB`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `friend_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `socket_id` varchar(30) NOT NULL,
  `server_id` varchar(30) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `ips` (
  `ip` varchar(45) NOT NULL,
  `count` int(3) NOT NULL,
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `mods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `room_name` varchar(16) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `username` varchar(16) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `permissions` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `room` (`room_name`,`username`),
  KEY `user_id` (`username`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `playlists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `room_name` varchar(16) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `JSON` mediumblob NOT NULL,
  PRIMARY KEY (`id`),
  KEY `room_name` (`room_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `playlist_dumps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `room_name` varchar(16) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `JSON` mediumblob NOT NULL,
  PRIMARY KEY (`id`),
  KEY `room_name` (`room_name`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `resets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(73) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `user_id` int(11) NOT NULL,
  `time` int(11) NOT NULL,
  `ip` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `rooms` (
  `room_id` int(11) NOT NULL,
  `room_name` varchar(16) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(160) COLLATE utf8_unicode_ci DEFAULT 'No Description',
  `users` int(11) NOT NULL DEFAULT '0',
  `thumbnail` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `visits` int(11) NOT NULL DEFAULT '0',
  `title` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `listing` enum('public','private') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'public',
  `info` varchar(2048) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'No Info',
  `NSFW` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`room_id`),
  UNIQUE KEY `roomname` (`room_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `cookie` varchar(80) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `username` varchar(16) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `last_used` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `username` (`username`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(16) COLLATE utf8_unicode_ci NOT NULL,
  `hashpw` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `cookie` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `avatar` varchar(8) COLLATE utf8_unicode_ci NOT NULL DEFAULT '1IAsQI0',
  `bio` varchar(1024) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'No Bio',
  `social` tinyint(1) NOT NULL DEFAULT '1',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `registered_ip` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


ALTER TABLE `bans`
  ADD CONSTRAINT `bans_ibfk_1` FOREIGN KEY (`room_name`) REFERENCES `rooms` (`room_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `bans_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `friends_list`
  ADD CONSTRAINT `friends_list_ibfk_3` FOREIGN KEY (`sentBy`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `friends_list_ibfk_4` FOREIGN KEY (`userA`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `friends_list_ibfk_5` FOREIGN KEY (`userB`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `friend_requests`
  ADD CONSTRAINT `friend_requests_ibfk_1` FOREIGN KEY (`userA`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `friend_requests_ibfk_2` FOREIGN KEY (`userB`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `friend_requests_ibfk_3` FOREIGN KEY (`sentBy`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `friend_status`
  ADD CONSTRAINT `friend_status_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `mods`
  ADD CONSTRAINT `mods_ibfk_3` FOREIGN KEY (`room_name`) REFERENCES `rooms` (`room_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `mods_ibfk_4` FOREIGN KEY (`username`) REFERENCES `users` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `playlists`
  ADD CONSTRAINT `playlists_ibfk_1` FOREIGN KEY (`room_name`) REFERENCES `rooms` (`room_name`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `playlist_dumps`
  ADD CONSTRAINT `playlist_dumps_ibfk_1` FOREIGN KEY (`room_name`) REFERENCES `rooms` (`room_name`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `resets`
  ADD CONSTRAINT `resets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `rooms`
  ADD CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `rooms_ibfk_2` FOREIGN KEY (`room_name`) REFERENCES `users` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sessions`
  ADD CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sessions_ibfk_2` FOREIGN KEY (`username`) REFERENCES `users` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;
