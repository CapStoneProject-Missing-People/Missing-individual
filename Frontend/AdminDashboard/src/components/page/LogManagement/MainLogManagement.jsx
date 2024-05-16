import React from "react";
import Log from "./Log";
import Title from '../../pagename/Title'

export default function MainLogManagement() {
    return (
      <div className="h-96">
        <Title pageName="Log management"/>
        <Log/>
      </div>
    )
  }

