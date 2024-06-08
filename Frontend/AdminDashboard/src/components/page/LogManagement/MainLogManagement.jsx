import React from "react";
import Log from "./Log";
import Title from '../../pagename/Title'
import TableComponentPresentation from './Table/TableComponentPresentation'

export default function MainLogManagement() {
    return (
      <div className="h-96">
        <Title pageName="Log management"/>
        <TableComponentPresentation/>
      </div>
    )
  }

