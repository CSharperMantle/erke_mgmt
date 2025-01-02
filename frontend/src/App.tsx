import Container from "@mui/material/Container"

import AuditorAccordion from "./component/AuditorAccordion"
import LoginAccordion from "./component/LoginAccordion"
import OrganizerAccordion from "./component/OrganizerAccordion"
import StudentAccordion from "./component/StudentAccordion"
import { LoginStateContextProvider } from "./state"

const App = () => {
  return (
    <>
      <LoginStateContextProvider>
        <Container
          maxWidth="md"
          sx={{
            pt: 4,
            pb: 4,
          }}
        >
          <LoginAccordion />
          <StudentAccordion />
          <OrganizerAccordion />
          <AuditorAccordion />
        </Container>
      </LoginStateContextProvider>
    </>
  )
}

export default App
