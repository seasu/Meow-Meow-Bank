import type { NextConfig } from "next";

const isProd = process.env.NODE_ENV === "production";
const basePath = isProd ? "/Meow-Meow-Bank" : "";

const nextConfig: NextConfig = {
  output: "export",
  basePath,
  assetPrefix: isProd ? "/Meow-Meow-Bank/" : undefined,
  images: {
    unoptimized: true,
  },
};

export default nextConfig;
