/*
  Warnings:

  - You are about to drop the column `isPrivate` on the `Groups` table. All the data in the column will be lost.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Groups" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "groupType" TEXT NOT NULL DEFAULT 'PERSONAL',
    "adminId" TEXT NOT NULL,
    CONSTRAINT "Groups_adminId_fkey" FOREIGN KEY ("adminId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Groups" ("adminId", "createdAt", "description", "id", "name") SELECT "adminId", "createdAt", "description", "id", "name" FROM "Groups";
DROP TABLE "Groups";
ALTER TABLE "new_Groups" RENAME TO "Groups";
CREATE UNIQUE INDEX "Groups_name_key" ON "Groups"("name");
CREATE INDEX "Groups_groupType_idx" ON "Groups"("groupType");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
