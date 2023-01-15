import React from "react";

export default ({ className, children }) => (
  <button className={`font-bold py-2 px-4 rounded ${className}`}>{children}</button>
)
