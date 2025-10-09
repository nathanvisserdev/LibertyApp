/*
  Warnings:

  - You are about to drop the `FollowRequest` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Follows` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the column `kind` on the `ConnectionRequest` table. All the data in the column will be lost.
  - You are about to drop the column `kind` on the `Connections` table. All the data in the column will be lost.
  - You are about to drop the column `autoAcceptFollows` on the `Users` table. All the data in the column will be lost.
  - You are about to drop the column `isCreator` on the `Users` table. All the data in the column will be lost.
  - Added the required column `type` to the `ConnectionRequest` table without a default value. This is not possible if the table is not empty.
  - Added the required column `type` to the `Connections` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX "FollowRequest_followerId_creatorId_status_key";

-- DropIndex
DROP INDEX "Follows_followerId_creatorId_key";

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "FollowRequest";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Follows";
PRAGMA foreign_keys=on;

-- CreateTable
CREATE TABLE "Creator" (
    "userId" TEXT NOT NULL PRIMARY KEY,
    "acceptsAllFollowRequests" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "Creator_userId_fkey" FOREIGN KEY ("userId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_ConnectionRequest" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "requesterId" TEXT NOT NULL,
    "addresseeId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "decidedAt" DATETIME,
    CONSTRAINT "ConnectionRequest_requesterId_fkey" FOREIGN KEY ("requesterId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ConnectionRequest_addresseeId_fkey" FOREIGN KEY ("addresseeId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_ConnectionRequest" ("addresseeId", "createdAt", "decidedAt", "id", "requesterId", "status") SELECT "addresseeId", "createdAt", "decidedAt", "id", "requesterId", "status" FROM "ConnectionRequest";
DROP TABLE "ConnectionRequest";
ALTER TABLE "new_ConnectionRequest" RENAME TO "ConnectionRequest";
CREATE INDEX "ConnectionRequest_requesterId_addresseeId_type_status_idx" ON "ConnectionRequest"("requesterId", "addresseeId", "type", "status");
CREATE TABLE "new_Connections" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "aId" TEXT NOT NULL,
    "bId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "since" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Connections_aId_fkey" FOREIGN KEY ("aId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Connections_bId_fkey" FOREIGN KEY ("bId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Connections" ("aId", "bId", "id", "since") SELECT "aId", "bId", "id", "since" FROM "Connections";
DROP TABLE "Connections";
ALTER TABLE "new_Connections" RENAME TO "Connections";
CREATE UNIQUE INDEX "Connections_aId_bId_type_key" ON "Connections"("aId", "bId", "type");
CREATE TABLE "new_Users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "firstName" TEXT,
    "lastName" TEXT,
    "username" TEXT,
    "dateOfBirth" DATETIME,
    "gender" BOOLEAN,
    "phoneNumber" TEXT,
    "zipCode" TEXT,
    "photo" TEXT,
    "about" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "new_Users" ("about", "createdAt", "dateOfBirth", "email", "firstName", "gender", "id", "lastName", "password", "phoneNumber", "photo", "username", "zipCode") SELECT "about", "createdAt", "dateOfBirth", "email", "firstName", "gender", "id", "lastName", "password", "phoneNumber", "photo", "username", "zipCode" FROM "Users";
DROP TABLE "Users";
ALTER TABLE "new_Users" RENAME TO "Users";
CREATE UNIQUE INDEX "Users_email_key" ON "Users"("email");
CREATE UNIQUE INDEX "Users_username_key" ON "Users"("username");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
