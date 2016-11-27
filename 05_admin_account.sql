USE auth;
SET
@username = "trinity",
@password = "trinity",
@email = "YOUREMAIL",
@expansion = 2, /* Set this to 0 for vanilla expansion, 1 for TBC Expansion, 2 for WOTLK, 3 for Cataclysm, 4 for MoP, 5 for WoD */
@gmlevel = 3, /* 0 = player, 1=GM, 2=Moderator, 3=Admin, 4=Console */
@realmid = -1, /* -1 = All Realms */
@ip = "127.0.0.1"; /* IP address to bind the world server to */

INSERT INTO account (username, sha_pass_hash, email, expansion)
VALUES (UPPER(@username), ( SHA1(CONCAT(UPPER(@username), ':', UPPER (@password))) ), @email, @expansion);

INSERT INTO account_access (id, gmlevel, RealmID)
VALUES ((SELECT id FROM account WHERE username = @username), @gmlevel, @realmid);

UPDATE realmlist SET address = @ip WHERE id = 1;
