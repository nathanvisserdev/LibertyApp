-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Groups" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "groupType" TEXT NOT NULL DEFAULT 'PRIVATE',
    "adminId" TEXT NOT NULL,
    CONSTRAINT "Groups_adminId_fkey" FOREIGN KEY ("adminId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Groups" ("adminId", "createdAt", "description", "groupType", "id", "name") SELECT "adminId", "createdAt", "description", "groupType", "id", "name" FROM "Groups";
DROP TABLE "Groups";
ALTER TABLE "new_Groups" RENAME TO "Groups";
CREATE INDEX "Groups_groupType_idx" ON "Groups"("groupType");
CREATE INDEX "Groups_adminId_idx" ON "Groups"("adminId");
CREATE UNIQUE INDEX "Groups_adminId_name_key" ON "Groups"("adminId", "name");
CREATE TABLE "new_Posts" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "content" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT NOT NULL,
    "groupId" TEXT,
    "visibility" TEXT NOT NULL DEFAULT 'PUBLIC',
    CONSTRAINT "Posts_userId_fkey" FOREIGN KEY ("userId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Posts_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "Groups" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_Posts" ("content", "createdAt", "groupId", "id", "userId") SELECT "content", "createdAt", "groupId", "id", "userId" FROM "Posts";
DROP TABLE "Posts";
ALTER TABLE "new_Posts" RENAME TO "Posts";
CREATE INDEX "Posts_createdAt_idx" ON "Posts"("createdAt");
CREATE INDEX "Posts_visibility_idx" ON "Posts"("visibility");
CREATE INDEX "Posts_groupId_idx" ON "Posts"("groupId");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
